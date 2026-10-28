{
  dir,
  exclude ? [ ],
  mainFile ? "default.nix",
}:

let
  files = builtins.readDir dir;
  fullExclude = [ "default" ] ++ exclude;

  isExcluded =
    name:
    let
      # `builtins.match` returns null when there is no match (e.g. a dotfile
      # like `.envrc.nix` whose first char is a dot). Fall back to the raw
      # name so we never hand `builtins.head` a null and crash the eval.
      matched = builtins.match "([^\\.]+).*" name;
      base = if matched == null then name else builtins.head matched;
    in
    builtins.elem base fullExclude;

in
builtins.concatMap (
  name:
  let
    path = dir + "/${name}";
    info = files.${name};
  in
  if isExcluded name then
    [ ]
  else if info == "regular" && builtins.match ".*\\.nix" name != null then
    [ path ]
  else if info == "directory" && builtins.pathExists (path + "/${mainFile}") then
    [ (path + "/${mainFile}") ]
  else
    [ ]
) (builtins.attrNames files)
