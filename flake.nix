{
  description = "loner's NixOS-Hyprland";

  inputs =
    let
      followsNixpkgs = url: {
        inherit url;
        inputs.nixpkgs.follows = "nixpkgs";
      };
    in
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
      nixpkgs-master.url = "github:NixOS/nixpkgs/master";

      # core infrastructure
      flake-parts = followsNixpkgs "github:hercules-ci/flake-parts";

      # https://github.com/DeterminateSystems/nix-src/releases
      determinate = followsNixpkgs "https://flakehub.com/f/DeterminateSystems/nix-src/3.14.0";
      nur = followsNixpkgs "github:nix-community/NUR";
      home-manager = followsNixpkgs "github:nix-community/home-manager/master";
      nixos-wsl = followsNixpkgs "github:nix-community/NixOS-WSL/main";

      # formatting / tooling
      treefmt-nix = followsNixpkgs "github:numtide/treefmt-nix";
      git-hooks = followsNixpkgs "github:cachix/git-hooks.nix";
      nix-index-database = followsNixpkgs "github:nix-community/nix-index-database";
      deploy-rs = followsNixpkgs "github:serokell/deploy-rs";

      # system / persistence / secrets
      disko = followsNixpkgs "github:nix-community/disko";
      sops-nix = followsNixpkgs "github:Mic92/sops-nix";
      preservation = followsNixpkgs "github:nix-community/preservation";
      nix-flatpak = followsNixpkgs "github:gmodena/nix-flatpak/?ref=latest";
      quadlet-nix = followsNixpkgs "github:SEIAROTg/quadlet-nix";

      # theming / appearance
      stylix = followsNixpkgs "github:danth/stylix";
      distro-grub-themes = followsNixpkgs "github:AdisonCavani/distro-grub-themes";
      honkai-railway-grub-theme = followsNixpkgs "github:voidlhf/StarRailGrubThemes";
      silentSDDM = followsNixpkgs "github:uiriansan/SilentSDDM";

      # desktop / wm
      hyprland = followsNixpkgs "github:hyprwm/Hyprland";
      quickshell = followsNixpkgs "github:quickshell-mirror/quickshell";

      # browsers
      firefox = followsNixpkgs "github:nix-community/flake-firefox-nightly";
      zen-browser = followsNixpkgs "github:0xc000022070/zen-browser-flake";

      # applications
      spicetify-nix = followsNixpkgs "github:Gerg-L/spicetify-nix";
      nvf = followsNixpkgs "github:notashelf/nvf";
      ncm-desktop = followsNixpkgs "github:lonerOrz/ncm-desktop";
      aagl = followsNixpkgs "github:ezKEa/aagl-gtk-on-nix";
      # personal / custom
      chaotic = followsNixpkgs "github:chaotic-cx/nyx";
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
