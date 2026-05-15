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

  systemd.user.services.wslg-wayland-fix = {
    description = "Keep WSLg wayland symlink alive";

    wantedBy = [ "default.target" ];

    serviceConfig = {
      Restart = "always";
      RestartSec = 2;

      ExecStart = "${pkgs.writeShellScript "wslg-wayland-fix" ''
        #!${pkgs.bash}/bin/bash
        set -eu

        while true; do
          if [ ! -L /run/user/1000/wayland-0 ]; then
            ln -sfn /mnt/wslg/runtime-dir/wayland-0 \
              /run/user/1000/wayland-0
          fi

          if [ ! -L /run/user/1000/wayland-0.lock ]; then
            ln -sfn /mnt/wslg/runtime-dir/wayland-0.lock \
              /run/user/1000/wayland-0.lock
          fi

          sleep 5
        done
      ''}";
    };
  };
}
