let
  dir = ./.;
  mainFile = "default.nix";
  exclude = [
    "sddm"
  ];
  files = builtins.readDir dir;
  fullExclude = [ "default" ] ++ exclude;

  isExcluded =
    name:
    let
      base = builtins.head (builtins.match "([^\\.]+).*" name);
    in
    builtins.elem base fullExclude;

  collected = builtins.concatMap (
    name:
    let
      path = dir + "/${name}";
      info = builtins.getAttr name files;
    in
    if isExcluded name then
      [ ]
    else if info == "regular" && builtins.match ".*\\.nix" name != null then
      [ (import path) ]
    else if info == "directory" && builtins.pathExists (path + "/${mainFile}") then
      [ (import (path + "/${mainFile}")) ]
    else
      [ ]
  ) (builtins.attrNames files);
in
{
  imports = collected;
}
