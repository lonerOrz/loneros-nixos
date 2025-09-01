{
  config,
  pkgs,
  username,
  ...
}:
{
  # Enable common container config files in /etc/containers
  virtualisation = {
    containers = {
      enable = true;
      registries.search = [
        "registry.cn-hangzhou.aliyuncs.com"
        "docker-0.unsee.tech"
        "docker.io"
      ]; # 镜像的仓库列表
      registries.insecure = [ ]; # 仓库不支持 TLS
      registries.block = [ ]; # 屏蔽的仓库
    };

    podman = {
      enable = true;
      package = pkgs.podman;
      dockerCompat = true; # 提供 Docker CLI 兼容层
      defaultNetwork.settings = {
        dns_enabled = true; # podman-compose 内部容器互通
        dns = [
          "8.8.8.8"
          "114.114.114.114"
        ];
        ipv6_enabled = true; # 启用 IPv6
      };

      # 自动清理所有未使用的容器、镜像、网络和卷，每周清理一次
      autoPrune = {
        enable = true;
        flags = [
          "--all"
          "--force"
          "--volumes"
        ];
        dates = "0 3 * * 0"; # 每周日凌晨3点
      };
    };
  };

  environment.systemPackages = with pkgs; [
    podman
    podman-compose # Compose 替代 Docker Compose
    dive # 镜像分析工具
    podman-tui # 命令行查看容器状态
    podlet # 生成 Podman Quadlet 配置
  ];

  users.users.${username}.extraGroups = [ "podman" ];

  hardware.nvidia-container-toolkit.enable = true; # 直通 NVIDIA GPU

  # 开启 Podman 自动更新定时器（用户级 systemd）
  systemd.user.timers.podman-auto-update = {
    description = "Podman auto-update timer";
    wantedBy = [ "default.target" ];
    upheldBy = [ "default.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    unitConfig = {
      ConditionUser = username;
    };
  };

  systemd.user.services.podman-auto-update = {
    description = "Podman auto-update service";
    serviceConfig = {
      ExecStart = "${pkgs.podman}/bin/podman auto-update";
    };
  };

  # systemd 容器管理示例（可选）
  # virtualisation.oci-containers = {
  #   backend = "podman";
  #   containers = {
  #     mycontainer = {
  #       image = "alpine";
  #       restart = "unless-stopped";
  #       environment = { MY_VAR = "value"; };
  #     };
  #   };
  # };
}
