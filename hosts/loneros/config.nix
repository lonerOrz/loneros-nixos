{
  pkgs,
  inputs,
  system,
  stable,
  ...
}:
let
  inherit (import ./variables.nix) keyboardLayout;
in
{
  imports = [
    ./hardware.nix
    ./users.nix
    ./home.nix
    ./dev.nix

    ../../system
    ../../programs
    ../../servers
    ../../modules
    ../../themes
  ];

  # Extra Module Options
  drivers.amdgpu.enable = false;
  drivers.intel.enable = false;
  drivers.nvidia.enable = true;
  drivers.nvidia-prime = {
    enable = false;
    intelBusID = "";
    nvidiaBusID = "";
  };
  vm.guest-services.enable = false;
  local.hardware-clock.enable = false;

  programs = {
    hyprland = {
      enable = true;
      # set the flake package
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.overrideAttrs (old: {
      #   buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.cmake ];
      #   cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      #     "-DCMAKE_CXX_FLAGS='-march=x86-64-v3 -O3'"
      #   ];
      #   NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -march=x86-64-v3 -O3";
      # }); # make sure to also set the portal package, so that they are in sync
      # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland; # xdph none git
      xwayland.enable = true;
    };
    xwayland.enable = true; # 兼容层

    # XFCE 桌面环境的默认文件管理器
    thunar.enable = true;
    thunar.plugins = with pkgs.xfce; [
      exo # XFCE 框架库
      mousepad # 文本编辑器
      thunar-archive-plugin # 管理压缩文件
      thunar-volman # 挂载和卸载移动设备
      tumbler # 生成文件缩略图的后台服务
    ];

    dconf.enable = true;
    seahorse.enable = true; # GNOME 密钥管理器
    fuse.userAllowOther = true; # 用户空间文件系统
  };

  environment.systemPackages = (
    with pkgs;
    [
      # System Packages
      curl
      wget
      duf # 查看系统磁盘的空间使用情况 better df
      eza # better ls
      killall # better kill
      ntfs3g # mount ntfs 格式磁盘
      openssl # SSL/TLS 安全通信、证书管理和加密。
      inxi # 查看和展示系统硬件和软件信息的命令行工具
      jq # 处理 JSON 数据
      ffmpeg
      yt-dlp
      unzip
      fzf
      chafa
      loupe # rust编译的图片查看器
      bat # better cat
      fd # better find
      zoxide
      bc
      duf # better du
      ripgrep # better grep
      file
      dos2unix
      just
      git

      libappindicator # 创建桌面应用程序指示器（即系统托盘图标）的库
      libnotify # 发送桌面通知的库
      pciutils # 查看和操作 PCI（外设组件互联）设备的命令行工具
      cpufrequtils # 控制和管理 Linux 系统中 CPU 频率的工具
      btrfs-progs # 提供了创建、管理和修复 Btrfs 文件系统的命令行工具
      xdg-user-dirs # 创建标准的用户目录结构
      xdg-utils # 用于桌面环境集成的工具，提供对桌面环境设置和操作的统一接口

      dconf # 存储应用程序的设置
      glib # for gsettings to work
      gsettings-qt # 访问和修改应用程序设置的工具

      # Hyprland Stuff
      hyprcursor # 鼠标
      hypridle # 休眠
      hyprlock # 锁屏
      hyprpicker # 提取色素
      hyprsunset # 护眼
      hyprshot # 截图
      nwg-displays # 管理显示器
      nwg-dock-hyprland # dock栏

      # hyprpanel
      hyprpanel # a bar
      wf-recorder # record by hyprpanel
      matugen # 图片取色 by hyprpanel
      power-profiles-daemon # 切换电源模式
      libgtop # 获取系统性能信息的库

      # Qt
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum # kvantum
      kdePackages.qt6ct
      kdePackages.qtstyleplugin-kvantum # kvantum
      kdePackages.qtwayland

      # GTK
      nwg-look # GTK主题管理工具
      gsettings-desktop-schemas
      gtk-engine-murrine # GTK+ 2.x 的一个 主题引擎

      # grimblast # grim + slurp
      grim # 截图
      slurp # 选择
      swappy # 截图注释

      # audio
      pamixer # 命令行音量控制工具
      pavucontrol # 图形化音频控制工具
      playerctl # 控制支持 MPRIS 协议的音频和视频播放器的播放行为

      cliphist # 管理和查看剪贴板历史记录
      wl-clipboard # 命令行工具，操作剪贴板

      brightnessctl # 控制显示器亮度的命令行工具

      swww # 设置和管理背景壁纸
      mpvpaper # 动态壁纸
      wallust # 图片取色
      imagemagick # 图像处理工具

      xarchiver # 文件归档管理器
      yad # 创建 图形化对话框和窗口 的工具，通常用于 shell 脚本中

      wlogout # Wayland 环境下的注销工具
      fastfetch
      mpv
      btop
      nvtopPackages.full # 显卡监控
      cava # 音乐可视化
      kitty # teminal
      polkit_gnome # GNOME 风格授权图形界面
      file-roller # GNOME 风格的归档管理器
      eog # GNOME 桌面环境中的一个图像查看器
      gnome-system-monitor # GNOME 风格监视器
      baobab # GNOME 桌面环境的一个磁盘使用情况分析工具
      rofi-wayland # 程序启动器
      swaynotificationcenter # swaync 用于通知
      waybar # 任务栏
    ]
  );

  # Services to start
  services = {
    # 禁用 X Server
    xserver = {
      enable = false;
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
    };

    # 监控硬盘健康的工具
    smartd = {
      enable = false;
      autodetect = true;
    };

    gvfs.enable = true; # 提供虚拟文件系统，允许你通过统一的接口访问网络和远程文件系统
    tumbler.enable = true; # 生成文件缩略图的后台服务
    udev.enable = true; # 设备管理器
    envfs.enable = true; # 许通过 /env 路径访问环境变量
    dbus.enable = true; # 进程间通信（IPC）的系统总线

    # 清理 SSD 上无用数据块的工具
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    libinput.enable = true; # 输入设备驱动
    fwupd.enable = true; # 管理和更新硬件固件
    upower.enable = true; # 管理电池、能源和电源管理的守护进程
    gnome.gnome-keyring.enable = true; # 用于存储和管理密码、密钥、证书等敏感数据的工具

    # 用于文件同步的工具
    # syncthing = {
    #   enable = false;
    #   user = "${username}";
    #   dataDir = "/home/${username}";
    #   configDir = "/home/${username}/.config/syncthing";
    # };
  };

  # For Electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
