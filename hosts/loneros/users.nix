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
    "electron-39.8.10"
    "minio-2025-10-15T17-29-55Z"
  ];

  environment.systemPackages =
    with pkgs;
    [
      # System Base
      libappindicator # 系统托盘图标库
      libnotify # 桌面通知库
      pciutils # PCI 设备查看
      cpufrequtils # CPU 频率管理
      socat # 双向数据流中继

      # CLI
      curl # HTTP 客户端
      wget # 文件下载器
      git # 版本控制
      jq # JSON 处理
      yq # YAML 处理
      eza # better ls
      bat # better cat
      fd # better find
      ripgrep # better grep
      duf # better df/du
      killall # 按名杀进程
      zoxide # 智能目录跳转
      fzf # 模糊搜索
      inxi # 硬件信息概览
      fastfetch # 系统信息展示
      file # 文件类型识别
      bc # 命令行计算器
      dos2unix # 换行符转换
      unzip # 解压 zip
      ffmpeg # 音视频处理
      yt-dlp # 视频下载
      chafa # 终端图片渲染
      ascii-image-converter # 图片转 ASCII
      libcaca # 图片转彩色字符
      translate-shell # 命令行翻译
      tuckr # dotfile 管理
      wtype # Wayland 模拟键入
      net-tools # 经典网络工具
      gum # Shell 脚本交互组件
      terminaltexteffects # 终端文本特效
      xeyes # X11 窗口测试

      # TUI
      btop # 系统资源监控
      nvtopPackages.full # GPU 监控
      cava # 音频可视化
      yazi # 文件管理器
      evil-helix_git # Helix + Vim 键位
      rsclock # 终端时钟
      asciinema # 终端录制
      asciinema-agg # cast 转 gif
      isd # systemd 管理
      kmon # 内核模块管理

      # GUI
      kitty # 终端模拟器
      ghostty # 终端模拟器
      rofi # 应用启动器
      dmenu # 极简菜单启动器
      waybar # 状态栏
      swaynotificationcenter # 通知中心
      wlogout # 注销菜单
      yad # Shell 图形对话框
      mpv # 视频播放器
      loupe # 图片查看器
      xarchiver # 归档管理器
      zed-editor # 代码编辑器
      vscodium-wrapper # VS Code 开源版
      obsidian-wrapper # 笔记工具
      telegram-desktop # 即时通讯
      element-desktop # Matrix 客户端
      qbittorrent-enhanced # BT 下载
      localsend # 局域网文件传输
      libreoffice-stable # 办公套件
      door-knocker # XDG Portal 检测
      keypunch # 打字练习
      osu-lazer-bin # 音游
      inputs.ncm-desktop.packages.${system}.ncm-desktop # 网易云音乐
    ]
    ++ [
      # custom packages
      (pkgs.callPackage ../../pkgs/shimeji/package.nix { })
    ]
    ++ (with pkgs.nur.repos.lonerOrz; [
      # NUR packages
      go-musicfox
      nsearch-tv
      chameleos
      wayclick
      sonar
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
