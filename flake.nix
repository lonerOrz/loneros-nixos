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
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    niri.url = "github:sodiboo/niri-flake";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    stylix.url = "github:danth/stylix";
    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    honkai-railway-grub-theme.url = "github:voidlhf/StarRailGrubThemes";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      flake-parts,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = systems;
      imports = [
        ./checks/default.nix
      ] ++ inputs.nixpkgs.lib.optional (inputs.treefmt-nix ? flakeModule) ./treefmt.nix;

      perSystem =
        {
          system,
          pkgs,
          lib,
          ...
        }:
        {
          devShells = import ./devShell/default.nix { inherit pkgs; };
          packages =
            import ./pkgs/default.nix {
              inherit pkgs;
              inherit system;
              inherit lib;
            }
            // {
              iso = inputs.nixos-generators.nixosGenerate {
                system = system;
                format = "iso";
                modules = [ ./iso/config.nix ];
              };
            };
        };

      flake = {
        nixosConfigurations =
          let
            hosts = {
              loneros = {
                system = "x86_64-linux";
                username = "loner";
              };
              # 快速安装远程 nixos 配置
              remote-vm = {
                system = "x86_64-linux";
                username = "test";
              };
            };
            mkStable =
              system:
              import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
          in
          builtins.mapAttrs (
            host: cfg:
            nixpkgs.lib.nixosSystem {
              system = cfg.system;
              specialArgs = {
                inherit inputs;
                inherit host;
                username = cfg.username;
                system = cfg.system;
                stable = mkStable cfg.system;
                pkgsv3 = inputs.chaotic.legacyPackages.${cfg.system}.pkgsx86_64_v3 or null;
              };
              modules = [
                ./hosts/${host}/config.nix
                ./overlays
                {
                  nixpkgs.overlays = [
                    inputs.hyprpanel.overlay
                    inputs.nur.overlays.default
                    inputs.niri.overlays.niri
                  ];
                }
                inputs.distro-grub-themes.nixosModules.${cfg.system}.default
                inputs.honkai-railway-grub-theme.nixosModules.${cfg.system}.default
                inputs.stylix.nixosModules.stylix
                inputs.chaotic.nixosModules.default
                inputs.lix-module.nixosModules.default
              ];
            }
          ) hosts;
      };
    };
}
