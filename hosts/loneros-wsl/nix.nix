{
  username,
  ...
}:

{
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;

    permittedInsecurePackages = [
      "electron-11.5.0" # NUR baidunetdisk needed
    ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command" # 启用 nix build, nix run, nix flake 等新命令
        "flakes"
        # "ca-derivations" # 启用内容寻址 derivation（Content Addressed Derivations）! lix 不再支持 ca-derivations 这个实验性特性
      ];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
