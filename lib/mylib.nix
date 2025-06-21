# lib/myLib.nix
{ nixpkgs-lib }:
rec {
  # 导入模块并附加额外属性
  importModule' = path: module: import path { lib = nixpkgs-lib; } // { extra = module; };

  # 将字符串转换为大写
  toUpperCase = str: nixpkgs-lib.toUpper str;

  # 生成带有前缀的属性集
  prefixedAttrs =
    prefix: attrs:
    nixpkgs-lib.mapAttrs' (name: value: {
      name = "${prefix}-${name}";
      value = value;
    }) attrs;

  # 生成版本化的包名
  packageVersions =
    pkg: versions:
    nixpkgs-lib.listToAttrs (
      map (v: {
        name = "${pkg}-${v}";
        value = {
          version = v;
        };
      }) versions
    );
}
