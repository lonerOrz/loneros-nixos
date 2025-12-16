{
  config,
  pkgs,
  username,
  ...
}:
{
  virtualisation.incus = {
    enable = true; # 启用 Incus daemon
    # startTimeout = 60; # 启动超时时间（秒）
    softDaemonRestart = true; # 允许软重启 daemon
    socketActivation = true; # 使用 systemd socket 激活模式

    # Agent 和客户端配置
    # agent.enable = true; # 启用 agent
    # clientPackage = pkgs.incus; # 指定 CLI 工具包

    # UI 配置
    ui.enable = true;
    ui.package = pkgs.incus-ui-canonical;

    # 指定 daemon 包
    package = pkgs.incus;
    lxcPackage = pkgs.lxc; # LXC 容器运行时依赖

    preseed = {
      config = { };

      networks = [
        {
          config = {
            "ipv4.address" = "10.250.0.1/24";
            "ipv6.address" = "auto";
          };
          description = "";
          name = "incusbr0";
          type = "bridge";
          project = "default";
        }
      ];

      storage_pools = [
        {
          config = {
            source = "/var/lib/incus/storage-pools/default";
          };
          description = "";
          name = "default";
          driver = "btrfs";
        }
      ];

      storage_volumes = [ ];

      profiles = [
        {
          config = { };
          description = "";
          devices = {
            eth0 = {
              name = "eth0";
              network = "incusbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
          };
          name = "default";
          project = "default";
        }
      ];

      projects = [ ];
      certificates = [ ];
      cluster_groups = [ ];
      cluster = null;
    };
  };

  users.users.${username}.extraGroups = [
    "incus"
    "incus-admin"
  ];

  # 系统服务和网络
  networking.firewall.allowedTCPPorts = [ 8443 ]; # Incus Web UI 默认端口
}
