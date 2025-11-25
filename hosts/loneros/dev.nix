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
  ];

  packagesForSystem = import ../../devShell/package.nix {
    inherit pkgs lib;
    modulesList = devModules;
  };
in
{
  environment.systemPackages =
    with pkgs;
    [
      openssl
      pkg-config
    ]
    ++ packagesForSystem.systemPackages;

  environment.variables = packagesForSystem.environmentVariables // {
    LD_LIBRARY_PATH = lib.mkDefault "${pkgs.glib}/lib:${pkgs.gobject-introspection}/lib";
  };
}
