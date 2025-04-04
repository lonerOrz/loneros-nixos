{
  inputs,
  system,
  username,
  host,
  stable,
  ...
}:
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
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
        enableNixpkgsReleaseCheck = false;
      };
      programs.home-manager.enable = true;
      imports = [
        ../../home
      ];
    };
  };
}
