{
  description = "loner's NixOS-Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # https://github.com/DeterminateSystems/nix-src/releases
    determinate.url = "https://flakehub.com/f/DeterminateSystems/nix-src/3.14.0";

    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    chaotic.url = "github:lonerOrz/nyx-loner";
    stylix.url = "github:danth/stylix";
    distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";
    honkai-railway-grub-theme.url = "github:voidlhf/StarRailGrubThemes";
    preservation.url = "github:nix-community/preservation";

    firefox.url = "github:nix-community/flake-firefox-nightly";
    hyprland.url = "github:hyprwm/Hyprland";
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nvf.url = "github:notashelf/nvf";
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    tuckr-nix.url = "github:lonerOrz/tuckr-nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      lib = nixpkgs.lib;
      hosts = import ./hosts.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      inherit systems;

      imports = [
        inputs.treefmt-nix.flakeModule
      ]
      ++ lib.optional (builtins.pathExists ./treefmt.nix) ./treefmt.nix;

      perSystem =
        {
          pkgs,
          lib,
          config,
          system,
          ...
        }:
        let
          pre-commit-check = inputs.git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              treefmt = {
                enable = true;
                package = config.treefmt.build.wrapper;
              };
              # statix.enable = true;
            };
          };
        in
        {
          _module.args.mylib = import ./lib { inherit lib pkgs; };

          devShells = import ./devShell/default.nix {
            inherit pkgs;
            gitHooks = pre-commit-check;
          };

          checks = {
            inherit pre-commit-check;
          }
          // inputs.deploy-rs.lib.${system}.deployChecks self.deploy;

          packages =
            import ./pkgs/default.nix {
              inherit pkgs lib;
            }
            // {
              iso =
                let
                  iso-nixos = nixpkgs.lib.nixosSystem {
                    inherit system;
                    specialArgs = { inherit inputs; };
                    modules = [
                      ./iso/config.nix
                      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    ];
                  };
                in
                iso-nixos.config.system.build.isoImage;
            };
        };

      flake = {
        nixosConfigurations =
          let
            mkPkgs =
              nixpkgsInput: system:
              import nixpkgsInput {
                inherit system;
                config.allowUnfree = true;
              };
          in
          builtins.mapAttrs (
            host: cfg:
            nixpkgs.lib.nixosSystem {
              system = cfg.system;
              specialArgs = {
                inherit inputs host;
                username = cfg.username;
                system = cfg.system;
                stable = mkPkgs inputs.nixpkgs-stable cfg.system;
                pkgsv3 = inputs.chaotic.legacyPackages.${cfg.system}.pkgsx86_64_v3 or null;
              };
              modules = [
                ./hosts/${host}/config.nix
                (import ./overlays inputs)
                ./secrets
                {
                  nixpkgs.overlays = [
                    inputs.nur.overlays.default
                  ];
                }
                inputs.distro-grub-themes.nixosModules.${cfg.system}.default
                inputs.honkai-railway-grub-theme.nixosModules.${cfg.system}.default
                inputs.stylix.nixosModules.stylix
                inputs.chaotic.nixosModules.default
              ];
            }
          ) hosts;
      };
    }
    // {
      deploy.nodes =
        let
          deployDir = ./deploy;
          nodeFiles = if builtins.pathExists deployDir then builtins.readDir deployDir else { };
          validNixFiles = lib.filterAttrs (
            name: type: type == "regular" && lib.hasSuffix ".nix" name
          ) nodeFiles;
          nodeNames = map (name: lib.removeSuffix ".nix" name) (lib.attrNames validNixFiles);

          nodes = lib.genAttrs nodeNames (
            nodeName:
            import (deployDir + "/${nodeName}.nix") {
              inherit inputs;
              nixosConfigurations = self.nixosConfigurations;
              hostConfig = hosts.${nodeName};
              nodeName = nodeName;
            }
          );
        in
        nodes;
    };
}
