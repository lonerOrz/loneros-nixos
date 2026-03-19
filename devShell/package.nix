{
  pkgs,
  lib,
  modulesList,
}:

let
  loadModulesForSystem =
    moduleList:
    let
      # Modules now return mkShell derivations, extract packages and env from them
      imported = map (name: (import ./${name}.nix { inherit pkgs; })) moduleList;
    in
    {
      # mkShell returns buildInputs + nativeBuildInputs, both should be included
      packages = pkgs.lib.flatten (map (m: (m.buildInputs or [ ]) ++ (m.nativeBuildInputs or [ ])) imported);
      env = builtins.foldl' (acc: m: acc // (m.env or { })) { } imported;
    };
  systemModules = loadModulesForSystem modulesList;

in
{
  systemPackages = systemModules.packages;
  environmentVariables = systemModules.env;
}
