{
  pkgs,
  lib,
  modulesList,
}:

let
  loadModulesForSystem =
    moduleList:
    let
      imported = map (name: import ./${name}.nix { inherit pkgs; }) moduleList;
    in
    {
      packages = lib.flatten (
        map (m: (m.buildInputs or [ ]) ++ (m.nativeBuildInputs or [ ]) ++ (m.packages or [ ])) imported
      );
      env = builtins.foldl' (acc: m: acc // (m.env or { })) { } imported;
    };

  systemModules = loadModulesForSystem modulesList;
in
{
  systemPackages = systemModules.packages;
  environmentVariables = systemModules.env;
}
