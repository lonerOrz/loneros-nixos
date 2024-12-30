{
  pkgs,
  inputs,
  system,
  username,
  ...
}: let
  inherit (import ./variables.nix) gitUsername;
in {
  users = {
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "video"
        "input"
        "audio"
      ];

      # define user packages here
      packages = with pkgs; [
        tree
      ];
    };

    defaultUserShell = pkgs.fish;
  };

  imports = [
    ../../programs/nh.nix
    ../../programs/docker.nix
    ../../programs/fcitx5.nix
    ../../programs/mpd.nix
    ../../programs/rclone.nix
    ../../programs/spotify.nix
  ];

  # 允许过期不维护的包
  nixpkgs.config.permittedInsecurePackages = [
    "electron-11.5.0"
  ];

  environment.shells = with pkgs; [fish];
  environment.systemPackages = with pkgs; [
    fzf
    chafa
    bat
    file
    neovim
    yazi
    spotify
    qbittorrent
    discord
    obs-studio
    localsend
    starship
    go-musicfox
    inputs.zen-browser.packages."${system}".default
    dos2unix
    zed-editor
    nur.repos.xddxdd.baidunetdisk
    translate-shell
    telegram-desktop
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # 在此添加缺失的动态库（这些库会对未打包的程序生效）
      glibc
      icu
    ];
  };

  programs = {
    fish.enable = true;
    starship.enable = true;
  };

}

