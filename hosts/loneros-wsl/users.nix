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

  environment.systemPackages =
    with pkgs;
    [
      # System Base
      curl # HTTP 客户端
      wget # 文件下载
      libappindicator # 系统托盘库
      libnotify # 桌面通知库
      net-tools # 基础网络

      # CLI
      duf # 磁盘空间
      eza # 目录列表
      killall # 终止进程
      inxi # 系统信息
      jq # JSON 处理
      yq # YAML 处理
      unzip # 解压工具
      fzf # 模糊查找
      bat # 文件查看
      fd # 文件查找
      zoxide # 目录跳转
      bc # 命令行计算
      ripgrep # 文本搜索
      file # 文件类型
      dos2unix # 换行转换
      pamixer # 音量控制
      playerctl # 媒体控制
      cliphist # 剪贴板历史
      wl-clipboard # Wayland 剪贴板
      imagemagick # 图像处理
      fastfetch # 系统展示
      translate-shell # 命令行翻译
      tuckr # 配置管理
      libcaca # 终端图像
      socat # 网络中继
      appimage-run # AppImage 运行
      dpkg # Debian 包
      ffmpeg # 音视频处理
      yt-dlp # 视频下载
      chafa # 终端看图
      xeyes # 鼠标眼睛
      ascii-image-converter # 图像转 ASCII

      # TUI
      yazi # 文件管理
      btop # 资源监控
      cava # 音频可视化
      asciinema # 终端录屏
      asciinema-agg # 录屏转 GIF

      # GUI
      mpv # 视频播放
      kitty # 终端模拟
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
