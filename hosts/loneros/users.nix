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
  inherit (import ./variables.nix)
    gitUsername
    shell
    lto
    native
    ;

  defaultShell = pkgs.${shell};
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
      uid = 1000;
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
    defaultUserShell = defaultShell;
  };

  # 允许过期不维护的包
  nixpkgs.config.permittedInsecurePackages = [
    "electron-11.5.0" # NUR baidunetdisk needed
    "minio-2025-10-15T17-29-55Z"
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
      nixfmt # 官方 nixfmt 风格
      nixd # Nix lsp
      gh # github cli
      jujutsu # better than git
      aircrack-ng # wifi hack
      socat # ipc
      yq # yaml 文件解析
      bintools
      udiskie # auto mount
      gum
      terminaltexteffects # 终端管道标准文本的视觉特效
      csound
      terraform # infrastructure as code
      unixtools.xxd
      dmenu
      wtype
      protobuf

      # tui
      lazygit
      neovim
      yazi
      rsclock # colock
      asciinema # rec demo.cast
      asciinema-agg # cast -> gif
      fuzzel
      posting # postman tui
      isd # systemd TUI
      kmon # 内核编译和管理TUI

      #gui
      qbittorrent-enhanced # qbee
      motrix
      localsend
      ghostty_git
      foot
      zed-editor
      telegram-desktop
      stable.rustdesk-flutter
      evil-helix_git # introduces Vim keybindings and more
      element-desktop
      foliate # epub reader
      bitwarden-desktop # 密码管理器
      kazumi # 番剧
      libreoffice-fresh
      # librecad # CAD
      # (dbeaver-bin.override { override_xmx = "1024m"; }) # 数据库管理
      door-knocker # protal check
      feishu
      blanket # 白噪音
      keypunch
      osu-lazer-bin
      inputs.ncm-desktop.packages.${system}.ncm-desktop

      # electron wrapper
      obsidian-wrapper
      vscodium-wrapper

      # cli tool
      neo-cowsay # fortune | cowsay --random --rainbow
      fortune
      pipes # grep
      figlet # ascii <font>
      cmatrix
      hollywood
      lolcat
      xeyes
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
      nsearch-tv
      chameleos
      wayclick
      sonar

      biu
      helium
      (noctalia.override {
        withNative = native;
        withLto = lto;
      })
      duolingo-desktop
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
      package = defaultShell;
    };
    starship.enable = true;
  };
}
