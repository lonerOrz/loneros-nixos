{
  pkgs,
  config,
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
    # groups."${username}" = {
    #   name = "${username}";
    #   members = ["${username}"];
    # }; # 创建用户组
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."loneros/loner/password".path;
      description = "${gitUsername}";
      # group = "${username}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "scanner"
        "lp"
        "video"
        "input"
        "audio"
      ];
      packages = with stable; [ tree ];
    };
    defaultUserShell = pkgs.${shell};
  };

  imports = [ ../../dotfile ];

  # 允许过期不维护的包
  nixpkgs.config.permittedInsecurePackages = [
    "electron-11.5.0" # NUR baidunetdisk needed
  ];

  # 我自己喜欢全局安装
  environment.systemPackages =
    with pkgs;
    [
      # software
      translate-shell # 命令行翻译
      starship
      stow # dotfiles needed
      libcaca # img2txt
      tectonic-unwrapped # TeX/LaTeX 公式渲染
      nixfmt-rfc-style # 官方 nixfmt 风格
      nixd # Nix lsp
      gh # github cli
      jujutsu # better than git

      go-musicfox
      lazygit
      bottom
      neovim
      yazi
      rmpc # music cli
      rsclock # colock
      asciinema # rec demo.cast
      asciinema-agg # cast -> gif
      posting # postman tui
      fuzzel
      networkmanager_dmenu
      isd # systemd TUI

      qbittorrent-enhanced # qbee
      motrix
      localsend
      inputs.ghostty.packages."${system}".default
      foot
      zed-editor
      telegram-desktop
      stable.rustdesk-flutter
      evil-helix_git # introduces Vim keybindings and more
      element-desktop
      libreoffice-still # 长久支持版本
      gimp # 图片编辑
      foliate # epub reader
      bitwarden # 密码管理器
      animeko # 番剧

      # electron wrapper
      obsidian-wrapper
      vscodium-wrapper
      code-cursor-wrapper

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
      nitch
      xorg.xeyes
      ascii-image-converter
    ]
    ++ [
      # 自定义软件包
      (pkgs.callPackage ../../pkgs/mpv-handler.nix { })
      (pkgs.callPackage ../../pkgs/turntable.nix { })
      (pkgs.callPackage ../../pkgs/shimeji/package.nix { })
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
