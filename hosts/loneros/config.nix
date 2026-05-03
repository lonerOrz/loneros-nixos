{
  lib,
  host,
  pkgs,
  inputs,
  stable,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  inherit (import ./variables.nix) keyboardLayout;

  clusterDir = ../../cluster;
  clusterFiles = builtins.attrNames (builtins.readDir clusterDir);
  matchedFiles = builtins.filter (
    name: lib.hasSuffix ".nix" name && lib.hasSuffix "-${host}.nix" name

  ) clusterFiles;
  importsFromCluster = map (name: clusterDir + "/${name}") matchedFiles;
in
{
  imports = [
    ./hardware.nix
    ./users.nix
    # ./home.nix
    ./dev.nix

    ../../system
    ../../programs
    ../../servers
    ../../modules
    ../../themes
  ]
  ++ importsFromCluster;

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
    xwayland.enable = true; # 兼容层
    fuse = {
      enable = true;
      userAllowOther = true; # 用户空间文件系统
    };
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
      rofi # 程序启动器
      swaynotificationcenter # swaync 用于通知
      waybar # 任务栏
    ]
  );

  # Services to start
  services = {
    # 禁用 X Server
    xserver = {
      enable = true;
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
  system.stateVersion = "26.11";
}
