{
  pkgs,
  config,
  inputs,
  system,
  username,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
    config.allowBroken = true;
  };
  # Cachix, Optimization settings and garbage collection automation
  nix = {
    package = pkgs.lix;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    channel.enable = true;
    extraOptions = ''
      warn-dirty = false
    '';
    settings = {
      auto-optimise-store = true;
      system-features = [
        "gccarch-x86-64-v3" # for chaotic-nyx pkgsx86_64-v3
      ];
      experimental-features = [
        "nix-command" # 启用 nix build, nix run, nix flake 等新命令
        "flakes"
        # "ca-derivations" # 启用内容寻址 derivation（Content Addressed Derivations）! lix 不再支持 ca-derivations 这个实验性特性
      ];
      substituters = [
        "https://hyprland.cachix.org"
        "https://cache.garnix.io" # add garnix cache form github loneros-nixos repo
        "https://nix-community.cachix.org"
        "https://loneros.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "loneros.cachix.org-1:dVCECfW25sOY3PBHGBUwmQYrhRRK2+p37fVtycnedDU="
      ];
      trusted-users = [
        "root"
        "${username}"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
