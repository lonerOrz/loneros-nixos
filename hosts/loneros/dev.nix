{
  pkgs,
  lib,
  ...
}:

let
  devModules = [
    "node"
    "python"
    "c"
    "rust"
    "lua"
    "go"
    "zig"
  ];

  packagesForSystem = import ../../devShell/package.nix {
    inherit pkgs lib;
    modulesList = devModules;
  };
in
{
  # Core development toolchains and libraries
  environment.systemPackages =
    packagesForSystem.systemPackages
    ++ (with pkgs; [
      just # 任务运行器
      protobuf # 序列化协议
      bintools # 二进制分析工具链
      unixtools.xxd # 十六进制查看

      tectonic-unwrapped # LaTeX 渲染引擎

      nixd
      nixfmt
    ]);

  # Global development environment variables
  environment.variables = packagesForSystem.environmentVariables // {
    LD_LIBRARY_PATH = lib.mkDefault "${pkgs.glib}/lib:${pkgs.gobject-introspection}/lib";
  };
}
