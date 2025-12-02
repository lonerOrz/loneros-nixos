{
  lib,
  inputs,
  pkgs,
  username,
  host,
  stable,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false; # You have set either `nixpkgs.config` or `nixpkgs.overlays` while using `home-manager.useGlobalPkgs`. This will soon not be possible.
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit
        inputs
        username
        system
        host
        stable
        ;
    };
    users.${username} = {
      home = {
        username = "${username}";
        homeDirectory = lib.mkForce "/home/${username}";
        stateVersion = "25.11";
        enableNixpkgsReleaseCheck = false;
      };
      programs.home-manager.enable = true;
      imports = [
        ../../home
      ];
    };
  };
}
