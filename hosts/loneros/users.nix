{
  pkgs,
  config,
  stable,
  inputs,
  username,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
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
    defaultUserShell = if shell == "fish" then pkgs.nur.repos.lonerOrz.fish else pkgs.${shell};
  };

  # 允许过期不维护的包
  nixpkgs.config.permittedInsecurePackages = [
    "electron-11.5.0" # NUR baidunetdisk needed
  ];

  # 我自己喜欢全局安装
  environment.systemPackages =
    with pkgs;
    [
      # base cli
      net-tools # 网络工具
      translate-shell # 命令行翻译
      starship
      stow # dotfiles needed
      tuckr # better than stow
      libcaca # img2txt
      tectonic-unwrapped # TeX/LaTeX 公式渲染
      nixfmt-rfc-style # 官方 nixfmt 风格
      nixd # Nix lsp
      gh # github cli
      jujutsu # better than git
      aircrack-ng # wifi hack
      socat # ipc
      yq # yaml 文件解析
      bintools
      udiskie # auto mount
      gpu-screen-recorder # record video
      satty # Screenshot Annotation
      gum
      terminaltexteffects # 终端管道标准文本的视觉特效
      csound
      terraform # infrastructure as code

      # tui
      lazygit
      bottom
      neovim
      yazi
      rmpc # music cli
      rsclock # colock
      asciinema # rec demo.cast
      asciinema-agg # cast -> gif
      fuzzel
      networkmanager_dmenu
      posting # postman tui
      isd # systemd TUI
      kmon # 内核编译和管理TUI

      #gui
      qbittorrent-enhanced # qbee
      motrix
      localsend
      ghostty
      foot
      rio
      zed-editor
      telegram-desktop
      stable.rustdesk-flutter
      evil-helix_git # introduces Vim keybindings and more
      element-desktop
      libreoffice-still # 长久支持版本
      foliate # epub reader
      bitwarden-desktop # 密码管理器
      kazumi # 番剧
      turntable # 音乐盒子
      librecad # CAD
      # (dbeaver-bin.override { override_xmx = "1024m"; }) # 数据库管理
      door-knocker # protal check
      feishu

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
      # hollywood # https://github.com/NixOS/nixpkgs/issues/461499
      lolcat
      nitch
      xorg.xeyes
      ascii-image-converter
    ]
    ++ [
      # custom packages
      (pkgs.callPackage ../../pkgs/shimeji/package.nix { })
    ]
    ++ (with pkgs.nur.repos.lonerOrz; [
      # NUR packages
      mpv-handler
      go-musicfox
      pear-desktop # youtube music
      gitfetch
      nsearch-tv
      nmgui
      neowall
      chameleos
      linux-desktop-gremlin
    ]);

  programs = {
    # 在此添加缺失的动态库（这些库会对未打包的程序生效）
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        glibc
        icu
      ];
    };
    ${shell} = {
      enable = true;
      package = if shell == "fish" then pkgs.nur.repos.lonerOrz.fish else pkgs.${shell};
    };
    starship.enable = true;
  };
}
