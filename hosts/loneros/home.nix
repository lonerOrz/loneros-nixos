{ inputs
, system
, username
, host
, stable
, ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs username host stable; };
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
        inputs.catppuccin.homeManagerModules.catppuccin
      ];
    };
  };
}
