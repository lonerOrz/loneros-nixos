# For update-packages workflow
# This file imports all packages in the current directory and its subdirectories.
{
  pkgs ? import <nixpkgs> { },
  dir ? ./.,
  pkgFileName ? "package.nix",
}:

let
  lib = pkgs.lib;

  # readDir 只会在本次 evaluation 中执行一次
  entries = builtins.readDir dir;

  excludedNames = [ "default.nix" ];

  names = lib.filter (name: !(lib.elem name excludedNames)) (builtins.attrNames entries);

  mkEntry =
    name:
    let
      kind = entries.${name};
      path = dir + "/${name}";
    in
    if kind == "regular" && lib.hasSuffix ".nix" name then
      let
        drv = pkgs.callPackage path { };
      in
      {
        name = lib.removeSuffix ".nix" name;

        # 在这里统一扩展 passthru，避免在 fold 中反复 //
        value = drv // {
          passthru = (drv.passthru or { }) // {
            updateFile = path;
          };
        };
      }

    else if kind == "directory" then
      let
        subPath = path + "/${pkgFileName}";
      in
      if builtins.pathExists subPath then
        let
          drv = pkgs.callPackage subPath { };
        in
        {
          name = name;
          value = drv // {
            passthru = (drv.passthru or { }) // {
              updateFile = subPath;
            };
          };
        }
      else
        null
    else
      null;

in
# 使用 listToAttrs 一次性构造，避免 foldl' + // 的 O(n²)
lib.listToAttrs (lib.filter (x: x != null) (map mkEntry names))
