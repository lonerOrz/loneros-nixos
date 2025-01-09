{
  pkgs,
  stable,
  inputs,
  system,
  username,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername;
in
{
  users = {
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      extraGroups = [
        "networkmanager"
        "wheel"
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

  # 自定义软件安装
  imports = [
    ../../programs/nh.nix
    ../../programs/docker.nix
    ../../programs/fcitx5.nix
    ../../programs/mpd.nix
    ../../programs/rclone.nix
    ../../programs/spicetify.nix
    #../../programs/virtualbox.nix
    ../../programs/virt-manager.nix
    ../../programs/catppuccin.nix
    ../../programs/flatpak.nix
  ];

  # 允许过期不维护的包
  nixpkgs.config.permittedInsecurePackages = [
    "electron-11.5.0"
  ];

  environment.shells = with pkgs; [ fish ];
  environment.systemPackages = with pkgs; [
    # software
    fzf
    chafa
    bat
    file
    neovim
    yazi
    spotify
    #qbittorrent
    qbittorrent-enhanced # qbee
    discord
    #obs-studio
    localsend
    starship
    go-musicfox
    inputs.zen-browser.packages."${system}".default
    dos2unix
    zed-editor
    #nur.repos.xddxdd.baidunetdisk
    motrix
    translate-shell
    telegram-desktop
    tlrc
    kdenlive
    rustdesk-flutter
  ];

  programs = {
    # 在此添加缺失的动态库（这些库会对未打包的程序生效）
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        glibc
        icu
      ];
    };
    fish.enable = true;
    starship.enable = true;
  };

}
