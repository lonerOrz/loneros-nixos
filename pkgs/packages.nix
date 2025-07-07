{
  pkgs ? import <nixpkgs> { },
  dir ? ./.,
  pkgFileName ? "package.nix",
}:

let
  lib = pkgs.lib;
  entries = builtins.readDir dir;

  excludedNames = [ "default.nix" ];
  names = lib.filter (name: !(lib.elem name excludedNames)) (builtins.attrNames entries);

  importDir = lib.foldl' (
    acc: name:
    let
      path = dir + "/${name}";
      kind = entries.${name};
    in
    if kind == "regular" && lib.hasSuffix ".nix" name then
      let
        relativePath = dir + "/${name}";
        drv = pkgs.callPackage relativePath { };
      in
      acc
      // {
        "${lib.removeSuffix ".nix" name}" = drv // {
          passthru = (drv.passthru or { }) // {
            updateFile = relativePath;
          };
        };
      }
    else if kind == "directory" then
      let
        subPath = dir + "/${name}/${pkgFileName}";
      in
      if builtins.pathExists subPath then
        let
          drv = pkgs.callPackage subPath { };
        in
        acc
        // {
          "${name}" = drv // {
            passthru = (drv.passthru or { }) // {
              updateFile = subPath;
            };
          };
        }
      else
        acc
    else
      acc
  ) { } names;

in
importDir
