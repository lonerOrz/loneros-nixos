{
  lib,
  pkgs,
  config,
  options,
  username,
  ...
}:

let
  commonSettings = {
    registry-mirrors = [
      "https://registry.cn-hangzhou.aliyuncs.com"
      "https://docker-0.unsee.tech"
    ];
    experimental = true;
    dns = [
      "8.8.8.8"
      "8.4.4.8"
      "114.114.114.114"
    ];
  };

in
{
  config = lib.mkMerge (
    [
      {
        virtualisation.docker = {
          enable = true;
          enableOnBoot = true;
          storageDriver = "btrfs"; # 如果使用 btrfs 文件系统，可以设置存储驱动

          daemon.settings = commonSettings;

          # Rootless Docker
          rootless = {
            enable = true; # 启用无根模式
            setSocketVariable = true; # 设置 DOCKER_HOST 变量
            daemon.settings = lib.recursiveUpdate commonSettings {
              # data-root = "/home/${username}/docker-data"; # 设置 Docker 数据存储路径
              # userland-proxy = false;          # 禁用 userland-proxy
              # metrics-addr = "0.0.0.0:9323";   # 启用度量指标
              ipv6 = true; # 启用 IPv6
              # fixed-cidr-v6 = "fd00::/80";     # 设置固定 IPv6 地址范围
            };
          };
        };

        environment.systemPackages = with pkgs; [
          docker-compose
        ];

        # 配置 Docker 容器作为 systemd 服务运行
        # virtualisation.oci-containers = {
        #   backend = "docker";  # 使用 Docker 作为后端
        #   containers = {
        #     mycontainer = {
        #       # 容器的配置
        #       image = "alpine";  # 使用 Alpine 镜像
        #       restart = "unless-stopped";  # 容器停止后自动重启
        #       environment = { MY_VAR = "value"; };  # 环境变量
        #     };
        #   };
        # };

        # 将用户添加到 docker 组
        users.users.${username}.extraGroups = [ "docker" ];

        # 为容器启用 GPU 直通
        hardware.nvidia-container-toolkit.enable = true;
      }
    ]
    ++ lib.optional (options ? wsl) {
      hardware.nvidia-container-toolkit = {
        mount-nvidia-executables = false;
        suppressNvidiaDriverAssertion = true;
      };

      wsl.docker-desktop.enable = true;
      wsl.useWindowsDriver = true;
    }
  );
}
