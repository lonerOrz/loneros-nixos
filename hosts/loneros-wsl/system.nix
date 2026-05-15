{
  pkgs,
  config,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    package = pkgs.mesa;
    enable32Bit = true;
    package32 = pkgs.pkgsi686Linux.mesa;

    extraPackages = with pkgs; [
      libGL # OpenGL 核心（WSLg 强制依赖）
      libva # 通用视频加速接口
      libva-utils # VA-API 测试工具
      libvdpau # 通用视频解码库
      vdpauinfo # 视频解码检测工具
    ];
  };

  environment.systemPackages = with pkgs; [
    vulkan-tools # Vulkan 测试
    mesa-demos # Mesa 官方演示工具
  ];

  systemd.user = {
    services.wslg-wayland = {
      description = "WSLg Wayland 套接字自动链接";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = [
          "/run/current-system/sw/bin/mkdir -p /run/user/%U"
          "/run/current-system/sw/bin/chmod 700 /run/user/%U"
          "/run/current-system/sw/bin/ln -sf /mnt/wslg/runtime-dir/wayland-0* /run/user/%U/"
        ];
      };
    };

    # 路径监控：事件驱动（目录变化 → 自动修复）
    paths.wslg-wayland-watch = {
      description = "WSLg Wayland 目录监控";
      wantedBy = [ "default.target" ];
      pathConfig = {
        PathChanged = "/run/user/%U";
        Unit = "wslg-wayland.service";
      };
    };
  };
}
