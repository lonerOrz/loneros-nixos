# Main default config
{
  pkgs,
  inputs,
  ...
}:
let
  inherit (import ./variables.nix) keyboardLayout;
  python-packages = pkgs.python3.withPackages (
    ps: with ps; [
      requests
      pyquery # needed for hyprland-dots Weather script
    ]
  );
in
{
  imports = [
    ./hardware.nix
    ./users.nix

    ../../modules/amd-drivers.nix
    ../../modules/nvidia-drivers.nix
    ../../modules/nvidia-prime-drivers.nix
    ../../modules/intel-drivers.nix
    ../../modules/vm-guest-services.nix
    ../../modules/local-hardware-clock.nix

    ../../system/bluetooth.nix
    ../../system/nix.nix
    ../../system/boot.nix
    ../../system/networking.nix
    ../../system/xdg-portal.nix
    ../../system/pipewire.nix
    ../../system/security.nix
    ../../system/sddm.nix
    # ../../system/greet.nix
    ../../system/hardware.nix
    ../../system/timezone.nix
    ../../system/fonts.nix

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
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
    };
    xwayland.enable = true; # 兼容层

    waybar.enable = true;
    hyprlock.enable = true;
    neovim.enable = true;

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
    mtr.enable = true; # 网络诊断工具
    nm-applet.indicator = true; # NetworkManager 图形界面工具

    # 管理 GPG 密钥
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Overlays
  nixpkgs.overlays = [
    (import ../../overlays/xdg-desktop-portal-wlr.nix)
  ];

  environment.systemPackages =
    (with pkgs; [
      # System Packages
      clang # C,C++
      curl
      wget
      duf # 查看系统磁盘的空间使用情况 better df
      eza # better ls
      killall # better kill
      ffmpeg
      yt-dlp
      unzip
      fzf
      chafa
      bat
      ripgrep
      file
      dos2unix
      git

      libappindicator # 创建桌面应用程序指示器（即系统托盘图标）的库
      libnotify # 发送桌面通知的库
      openssl # 用于支持 Rainbow borders 一种自定义窗口边框的工具
      pciutils # 查看和操作 PCI（外设组件互联）设备的命令行工具
      cpufrequtils # 控制和管理 Linux 系统中 CPU 频率的工具
      btrfs-progs # 提供了创建、管理和修复 Btrfs 文件系统的命令行工具
      xdg-user-dirs # 创建标准的用户目录结构
      xdg-utils # 用于桌面环境集成的工具，提供对桌面环境设置和操作的统一接口

      glib # for gsettings to work
      dconf # 存储应用程序的设置
      gsettings-qt # 访问和修改应用程序设置的工具

      # Hyprland Stuff
      hyprcursor
      hypridle
      hyprlock
      hyprpicker
      hyprsunset
      pyprland # plugins

      # Qt
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum # kvantum
      kdePackages.qt6ct
      kdePackages.qtstyleplugin-kvantum # kvantum
      kdePackages.qtwayland

      # GTK
      nwg-look # GTK主题管理工具
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
      wallust # 图片取色
      imagemagick # 图像处理工具
      inxi # 查看和展示系统硬件和软件信息的命令行工具
      jq # 处理 JSON 数据
      xarchiver # 文件归档管理器
      yad # 创建 图形化对话框和窗口 的工具，通常用于 shell 脚本中
      wlogout # Wayland 环境下的注销工具
      ags # note: defined at flake.nix to download and install ags v1
      fastfetch
      (mpv.override { scripts = [ mpvScripts.mpris ]; }) # with tray
      btop
      cava # 音乐可视化
      kitty # teminal
      networkmanagerapplet # GNOME 桌面环境的 NetworkManager 图形化客户端
      polkit_gnome # GNOME 风格授权图形界面
      file-roller # GNOME 风格的归档管理器
      eog # GNOME 桌面环境中的一个图像查看器
      gnome-system-monitor # GNOME 风格监视器
      baobab # GNOME 桌面环境的一个磁盘使用情况分析工具
      nvtopPackages.full # 显卡监控
      rofi-wayland # 程序启动器
      swaynotificationcenter # swaync 用于通知
      (pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      })) # 启用了 Waybar 的实验性功能

    ])
    ++ [
      python-packages
    ];

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
    rpcbind.enable = false; # 基于 RPC（远程过程调用）的网络服务提供支持
    nfs.server.enable = false; # 共享本地文件系统
    openssh.enable = true; # SSH
    fwupd.enable = true; # 管理和更新硬件固件
    upower.enable = true; # 管理电池、能源和电源管理的守护进程
    gnome.gnome-keyring.enable = true; # 用于存储和管理密码、密钥、证书等敏感数据的工具

    # 打印机支持的配置
    # printing = {
    #   enable = false;
    #   drivers = [
    #  pkgs.hplipWithPlugin
    #   ];
    # };

    # 启用 IPP-over-USB 服务，它允许打印机通过 USB 连接使用
    # ipp-usb.enable = true;

    # 局域网内设备发现的服务
    # avahi = {
    #   enable = true;
    #   nssmdns4 = true;
    #   openFirewall = true;
    # };

    # 用于文件同步的工具
    # syncthing = {
    #   enable = false;
    #   user = "${username}";
    #   dataDir = "/home/${username}";
    #   configDir = "/home/${username}/.config/syncthing";
    # };

  };

  # zram 在内存中创建压缩交换空间的技术
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 30;
    swapDevices = 1;
    algorithm = "zstd";
  };

  # 调整系统的电源管理设置
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil"; # 基于调度器的 CPU 频率调节器
  };

  # For Electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
