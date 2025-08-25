{
  dir ? ./.,
  exclude ? [ ],
  mainFile ? "default.nix",
}:
let
  files = builtins.readDir dir;
  fullExclude = [ "default" ] ++ exclude;

  isExcluded =
    name:
    let
      base = builtins.head (builtins.match "([^\\.]+).*" name);
    in
    builtins.elem base fullExclude;

in
builtins.concatMap (
  name:
  let
    path = "${dir}/${name}";
    info = builtins.getAttr name files;
  in
  if isExcluded name then
    [ ]
  else if info == "regular" && builtins.match ".*\\.nix" name != null then
    [ path ]
  else if info == "directory" && builtins.pathExists "${path}/${mainFile}" then
    [ "${path}/${mainFile}" ]
  else
    [ ]
) (builtins.attrNames files)
