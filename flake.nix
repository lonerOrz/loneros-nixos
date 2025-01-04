{
  description = "loner's NixOS-Hyprland";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #wallust.url = "git+https://codeberg.org/explosion-mental/wallust?ref=dev";
    home-manager = {
      url = "github:nix-community/home-manager/master"; # or release-24.11
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    catppuccin.url = "github:catppuccin/nix";
    hyprland.url = "github:hyprwm/Hyprland"; # hyprland development
    stylix.url = "github:danth/stylix";
    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    zen-browser.url = "git+https://git.sr.ht/~canasta/zen-browser-flake/";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      nur,
      home-manager,
      flake-utils,
      ...
    }:
    let
      system = "x86_64-linux";
      host = "loneros";
      username = "loner";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      lib = nixpkgs.lib;

    in
    {
      nixosConfigurations = {
        "${host}" = lib.nixosSystem rec {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit username;
            inherit host;
          };
          modules = [
            ./hosts/${host}/config.nix
            inputs.distro-grub-themes.nixosModules.${system}.default
            inputs.catppuccin.nixosModules.catppuccin
            inputs.stylix.nixosModules.stylix
            inputs.nur.modules.nixos.default
            # nixos module intall home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} ={
                imports = [
                  ./hosts/${host}/home.nix
                  inputs.catppuccin.homeManagerModules.catppuccin
                ];
              }; 
            }
          ];
        };
      };
      # Standalone install home-manager
      #homeConfigurations = {
      #  "${username}" = home-manager.lib.homeManagerConfiguration {
      #    extraSpecialArgs = {
      #      inherit system;
      #      inherit inputs;
      #      inherit username;
      #      inherit host;
      #    };
      #    pkgs = nixpkgs.legacyPackages.${system};
      #    modules = [
      #      ./hosts/${host}/home.nix
      #    ];
      #  };
      #};
      formatter.${system} = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
