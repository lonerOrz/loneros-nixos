{ pkgs, modulesList }:

let
  loadModulesForSystem =
    moduleList:
    let
      imported = map (name: import ./${name}.nix { inherit pkgs; }) moduleList;
    in
    {
      packages = pkgs.lib.flatten (map (m: m.packages or [ ]) imported);
      env = builtins.foldl' (acc: m: acc // (m.env or { })) { } imported;
    };
  systemModules = loadModulesForSystem modulesList;

in
{
  systemPackages = systemModules.packages;
  environmentVariables = systemModules.env;
}
