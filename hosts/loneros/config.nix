{
  lib,
  host,
  ...
}:
let
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
    (if builtins.pathExists ./hardware.nix then ./hardware.nix else { })
    ./disko.nix
    ./persist.nix
    ./users.nix
    # ./home.nix
    ./dev.nix

    ../../system
    ../../programs
    ../../servers
    ../../modules
    ../../themes
    ../../virtualisation
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
