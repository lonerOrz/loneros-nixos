{
  config,
  pkgs,
  username,
  ...
}:
{
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  # 如果使用 btrfs 文件系统，可以设置存储驱动
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.rootless = {
    enable = true; # 启用无根模式
    setSocketVariable = true; # 设置 DOCKER_HOST 变量
    daemon.settings = {
      # data-root = "/home/${username}/docker-data"; # 设置 Docker 数据存储路径
      registry-mirrors = [
        "https://registry.cn-hangzhou.aliyuncs.com"
        "https://docker-0.unsee.tech"
      ];
      #userland-proxy = false;          # 禁用 userland-proxy
      experimental = true; # 启用实验性功能
      dns = [
        "8.8.8.8"
        "8.8.4.4"
        "114.114.114.114"
      ]; # 设置 Docker 使用的 DNS
      #metrics-addr = "0.0.0.0:9323";   # 启用度量指标
      #ipv6 = true;                    # 启用 IPv6
      #fixed-cidr-v6 = "fd00::/80";    # 设置固定 IPv6 地址范围
    };
  };
  # 配置 Docker Daemon 的其他设置
  virtualisation.docker.daemon.settings = {
    # data-root = "/home/${username}/docker-data"; # 设置 Docker 数据存储路径
    registry-mirrors = [
      "https://registry.cn-hangzhou.aliyuncs.com"
      "https://docker-0.unsee.tech"
    ];
    #userland-proxy = false;          # 禁用 userland-proxy
    experimental = true; # 启用实验性功能
    dns = [
      "8.8.8.8"
      "8.8.4.4"
      "114.114.114.114"
    ]; # 设置 Docker 使用的 DNS
    #metrics-addr = "0.0.0.0:9323";   # 启用度量指标
    #ipv6 = true;                    # 启用 IPv6
    #fixed-cidr-v6 = "fd00::/80";    # 设置固定 IPv6 地址范围
  };
  # 安装 Docker Compose
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

  # 配置用户权限：将用户添加到 docker 组以便访问 Docker 套接字
  users.users.${username}.extraGroups = [ "docker" ]; # 将用户添加到 docker 组
  # 如果你希望为容器启用 GPU 直通，可以使用以下配置：
  hardware.nvidia-container-toolkit.enable = true;
}
