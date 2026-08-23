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
      tuckr # better than stow
      libcaca # img2txt
      tectonic-unwrapped # TeX/LaTeX 公式渲染
      nixfmt # 官方 nixfmt 风格
      nixd # Nix lsp
      socat # ipc
      yq # yaml 文件解析
      bintools
      unixtools.xxd

      # dev package
      appimage-run
      dpkg

      # tui
      lazygit
      neovim
      yazi
      asciinema # rec demo.cast
      asciinema-agg # cast -> gif

      # cli tool
      cmatrix
      xeyes
      ascii-image-converter
    ]
    ++ [
      # custom packages
      (pkgs.callPackage ../../pkgs/shimeji/package.nix { })
    ]
    ++ (with pkgs.nur.repos.lonerOrz; [
      # NUR packages
      gitfetch
      nsearch-tv
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
      package = pkgs.${shell};
    };
    starship.enable = true;
  };
}
