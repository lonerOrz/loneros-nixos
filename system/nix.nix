{
  config,
  inputs,
  system,
  username,
  ...
}: let
  hasCpuFlag = flag: builtins.match (".*" + flag + ".*") (builtins.readFile "/proc/cpuinfo") != null;
in {
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = {
      gcc.arch =
        if hasCpuFlag "avx2"
        then "x86-64-v3"
        else "x86-64";
      system = "${system}";
    };
  };
  # Cachix, Optimization settings and garbage collection automation
  nix = {
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
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
        "ca-derivations" # 启用内容寻址 derivation（Content Addressed Derivations）
      ];
      substituters = [
        "https://hyprland.cachix.org"
        "https://cache.garnix.io" # add garnix cache form github loneros-nixos repo
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
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
