{
  description = "loner's NixOS-Hyprland";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master"; # or release-24.11
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    catppuccin.url = "github:catppuccin/nix";
    #hyprland.url = "github:hyprwm/Hyprland"; # hyprland development
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    stylix.url = "github:danth/stylix";
    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    zen-browser.url = "git+https://git.sr.ht/~canasta/zen-browser-flake/";
    ags.url = "github:aylur/ags/v1"; # aylurs-gtk-shell-v1
    ghostty.url = "github:ghostty-org/ghostty";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      flake-utils,
      systems,
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

      stable = import nixpkgs-stable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      lib = nixpkgs.lib;

      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
                        treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

    in
    {
      nixosConfigurations = {
        "${host}" = lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit username;
            inherit host;
            inherit stable;
          };
          modules = [
            ./hosts/${host}/config.nix
            {
              nixpkgs.overlays = [
                inputs.hyprpanel.overlay
              ];
            }
            inputs.distro-grub-themes.nixosModules.${system}.default
            inputs.catppuccin.nixosModules.catppuccin
            inputs.stylix.nixosModules.stylix
            inputs.nur.modules.nixos.default
            inputs.chaotic.nixosModules.default
            # nixos module intall home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                inherit host;
                inherit stable;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = {
                imports = [
                  ./hosts/${host}/home.nix
                  inputs.catppuccin.homeManagerModules.catppuccin
                  inputs.chaotic.homeManagerModules.default
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
      # formatter.${system} = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
