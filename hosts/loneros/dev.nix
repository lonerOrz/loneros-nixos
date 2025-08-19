{ pkgs, ... }:

let
  devModules = [
    "node"
    "python"
    "c"
    "rust"
    "lua"
    "go"
  ];

  packagesForSystem = import ../../devShell/package.nix {
    inherit pkgs;
    modulesList = devModules;
  };
in
{
  environment.systemPackages = packagesForSystem.systemPackages;

  # 可选：导入模块提供的环境变量
  environment.variables = packagesForSystem.environmentVariables;
}
