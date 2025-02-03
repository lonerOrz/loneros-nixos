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
    ../../programs/fcitx5.nix
    ../../programs/mpd.nix
    ../../programs/spicetify.nix
    ../../programs/catppuccin.nix
    ../../programs/discord.nix
    ../../programs/firefox.nix
  ];

  # 安装的软件
  environment.systemPackages = with pkgs; [
    # software
    starship
    devbox
    stow
    yazi

    spotify
    qbittorrent-enhanced # qbee
    inputs.zen-browser.packages."${system}".default
    zed-editor
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
