# Overlay for PR fixes that are merged in nixpkgs-master but not yet in nixpkgs-unstable
inputs:

final: prev:
let
  pkgsMaster = import inputs.nixpkgs-master {
    system = final.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  hotfixes = {
    bitwarden-desktop = "500223";
  };

in
builtins.mapAttrs (name: prId: pkgsMaster.${name}) hotfixes
