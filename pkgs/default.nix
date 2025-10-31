# Export some custom packages to anyone who imports this flake.
{
  pkgs,
  lib,
  mylib,
  dir ? ./.,
  pkgFileName ? "package.nix",
  excluded ? [
    "default"
    "packages"
    "qq"
  ],
}:
let
  entries = builtins.readDir dir;
  names = lib.filter (
    name:
    let
      baseName = if lib.hasSuffix ".nix" name then lib.removeSuffix ".nix" name else name;
    in
    !(lib.elem baseName excluded)
  ) (builtins.attrNames entries);
  importDir = lib.foldl' (
    acc: name:
    let
      kind = entries.${name};
    in
    if kind == "regular" && lib.hasSuffix ".nix" name then
      let
        drv = pkgs.callPackage (builtins.toString dir + "/" + name) { };
      in
      acc // { "${lib.removeSuffix ".nix" name}" = drv; }
    else if kind == "directory" then
      let
        subPath = builtins.toString dir + "/" + name + "/" + pkgFileName;
      in
      if builtins.pathExists subPath then
        let
          drv = pkgs.callPackage subPath { };
        in
        acc // { "${name}" = drv; }
      else
        acc
    else
      acc
  ) { } names;
in
importDir
