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
    hyprland.url = "github:hyprwm/Hyprland"; # hyprland development
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    Hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:aylur/ags/v1";
    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    honkai-railway-grub-theme.url = "github:voidlhf/StarRailGrubThemes"; # 星铁grub
    zen-browser.url = "git+https://git.sr.ht/~canasta/zen-browser-flake/";
    ghostty.url = "github:ghostty-org/ghostty";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nvf.url = "github:notashelf/nvf";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
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
            inputs.honkai-railway-grub-theme.nixosModules.${system}.default
            inputs.catppuccin.nixosModules.catppuccin
            inputs.stylix.nixosModules.stylix # 包含home-manager的覆盖
            inputs.nur.modules.nixos.default
            inputs.chaotic.nixosModules.default
          ];
        };
      };
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
