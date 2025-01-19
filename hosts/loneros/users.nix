{
  pkgs,
  stable,
  inputs,
  system,
  username,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername shell;
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
    ../../programs/virt-manager.nix
    ../../programs/catppuccin.nix
    #../../programs/flatpak.nix
    ../../programs/steam.nix
    ../../programs/wayvnc.nix
    ../../programs/ollama.nix
  ];

  # 允许过期不维护的包
  nixpkgs.config.permittedInsecurePackages = [
    "electron-11.5.0"
  ];
  # 安装的软件
  environment.systemPackages = with pkgs; [
    # software
    fzf
    chafa
    bat
    ripgrep
    file
    neovim
    yazi
    spotify
    qbittorrent-enhanced # qbee
    discord
    localsend
    starship
    go-musicfox
    inputs.zen-browser.packages."${system}".default
    dos2unix
    zed-editor
    motrix
    translate-shell
    telegram-desktop
    kdenlive
    rustdesk-flutter
    devbox
    lazygit
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
