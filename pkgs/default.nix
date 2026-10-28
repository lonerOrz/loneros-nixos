# Export some custom packages to anyone who imports this flake.
{
  pkgs,
  lib,
  dir ? ./.,
  pkgFileName ? "package.nix",
  excluded ? [
    "default"
  ],
}:

let
  entries = builtins.readDir dir;

  names = lib.filter (
    name:
    let
      base = if lib.hasSuffix ".nix" name then lib.removeSuffix ".nix" name else name;
    in
    !(lib.elem base excluded)
  ) (builtins.attrNames entries);

  # 不使用 foldl' + //，避免 O(n²) 合并成本
  mkEntry =
    name:
    let
      kind = entries.${name};
    in
    if kind == "regular" && lib.hasSuffix ".nix" name then
      {
        name = lib.removeSuffix ".nix" name;

        # 使用 path 拼接而不是 toString，保持 path 类型
        value = pkgs.callPackage (dir + "/${name}") { };
      }
    else if kind == "directory" then
      let
        subPath = dir + "/${name}/${pkgFileName}";
      in
      if builtins.pathExists subPath then
        {
          name = name;
          value = pkgs.callPackage subPath { };
        }
      else
        null
    else
      null;

in
# 一次性构造 attrset，复杂度 O(n)
lib.listToAttrs (lib.filter (x: x != null) (map mkEntry names))
