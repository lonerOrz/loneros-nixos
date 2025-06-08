{
  description = "loner's NixOS-Hyprland";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master"; # or release-24.11
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland"; # hyprland development
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    stylix.url = "github:danth/stylix";
    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    honkai-railway-grub-theme.url = "github:voidlhf/StarRailGrubThemes"; # 星铁grub
    zen-browser.url = "github:0xc000022070/zen-browser-flake/a1ed62298f2bb4f6e26d42c92ccc40d59b334e46";
    ghostty.url = "github:ghostty-org/ghostty";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nvf.url = "github:notashelf/nvf";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    systems,
    ...
  }: let
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
  in {
    nixosConfigurations = {
      "${host}" = nixpkgs.lib.nixosSystem {
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
              inputs.nur.overlays.default
            ];
          }
          inputs.distro-grub-themes.nixosModules.${system}.default
          inputs.honkai-railway-grub-theme.nixosModules.${system}.default
          inputs.stylix.nixosModules.stylix # 包含home-manager的覆盖
          # inputs.nur.modules.nixos.default
          inputs.chaotic.nixosModules.default
          inputs.lix-module.nixosModules.default
        ];
      };
    };
  };
}
