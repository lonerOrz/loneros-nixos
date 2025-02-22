{ pkgs
, stable
, inputs
, system
, username
, ...
}:
let
  inherit (import ./variables.nix) gitUsername shell;
in
{
  users = {
    mutableUsers = true;
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
      packages = with stable; [
        tree
      ];
    };
    defaultUserShell = pkgs.${shell};
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
    ../../programs/virt-manager.nix # kvm + qemu + virt-manager
    ../../programs/tty-theme.nix # catppuccin-mocha
    #../../programs/flatpak.nix
    ../../programs/steam.nix
    ../../programs/wayvnc.nix
    #../../programs/ollama.nix
    ../../programs/wshowkeys.nix
    ../../programs/discord.nix
    ../../programs/firefox.nix
  ];

  # 允许过期不维护的包
  nixpkgs.config.permittedInsecurePackages = [
    "electron-11.5.0" # baidunetdisk needed
  ];

  # 安装的软件
  environment.systemPackages = with pkgs; [
    # software
    translate-shell
    starship
    devbox # 配合 direnv
    stow # dotfiles needed

    go-musicfox
    lazygit
    neovim
    yazi

    spotify
    qbittorrent-enhanced # qbee
    motrix
    localsend
    inputs.zen-browser.packages."${system}".default
    inputs.ghostty.packages."${system}".default
    zed-editor
    telegram-desktop
    rustdesk-flutter
    obsidian
    helix # 编辑器

    # dev
    waypaper
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
    ${shell}.enable = true;
    starship.enable = true;
  };

}
