# Export some custom packages to anyone who imports this flake.
{
  pkgs,
  lib,
  dir ? ./.,
  pkgFileName ? "package.nix",
  excluded ? [
    "default"
    "packages"
  ],
}:

let
  # 目录只读取一次；readDir 在同一次 evaluation 中会被共享
  entries = builtins.readDir dir;

  # 先过滤名字，避免后面重复判断
  names = lib.filter (
    name:
    let
      # 统一去掉 .nix 后再做 excluded 判断
      base = if lib.hasSuffix ".nix" name then lib.removeSuffix ".nix" name else name;
    in
    !(lib.elem base excluded)
  ) (builtins.attrNames entries);

  # 构造 { name, value }，最后统一 listToAttrs
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
