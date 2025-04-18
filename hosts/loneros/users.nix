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
      packages = with stable; [
        tree
      ];
    };
    defaultUserShell = pkgs.${shell};
  };

  security.sudo.extraRules = [
    {
      users = [ "${username}" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # 允许过期不维护的包
  nixpkgs.config.permittedInsecurePackages = [
    "electron-11.5.0" # NUR baidunetdisk needed
  ];

    # Overlays
  nixpkgs.overlays = [
    (import ../../overlays/code-cursor-wrapper.nix)
    (import ../../overlays/vscodium-wrapper.nix)
  ];

  # 我自己喜欢全局安装
  environment.systemPackages = with pkgs; [
    # software
    translate-shell
    starship
    devbox # 配合 direnv
    stow # dotfiles needed

    # hyde needed
    # parallel-full
    # envsubst

    spicetify-cli # flatpak installed spotify
    go-musicfox
    lazygit
    bottom
    neovim
    yazi
    rmpc # music cli
    rsclock # colock
    asciinema # rec demo.cast
    asciinema-agg # cast -> gif

    qbittorrent-enhanced # qbee
    motrix
    localsend
    inputs.zen-browser.packages."${system}".default
    inputs.ghostty.packages."${system}".default
    zed-editor
    telegram-desktop
    stable.rustdesk-flutter
    obsidian
    helix # 编辑器
    element-desktop
    libreoffice-still # 长久支持版本
    vscodium-wrapper
    code-cursor-wrapper # overlay code-cursor

    # cli tool
    neo-cowsay # fortune | cowsay --random --rainbow
    fortune
    pipes # grep
    sl
    figlet # ascii <font>
    bb
    cmatrix
    hollywood
    lolcat
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
