{
  pkgs,
  host,
  username,
  ...
}:
{
  # 是否启用 WSL 支持，让 NixOS 可以作为 WSL 发行版运行
  wsl.enable = true;

  # 默认登录用户
  wsl.defaultUser = "${username}";

  # 是否启用 Docker Desktop 集成
  wsl.docker-desktop.enable = true;

  wsl.wslConf = {
    # 自动挂载 Windows 驱动器
    automount = {
      enabled = true;
      # 是否修改 ld.so 配置以加载 Windows OpenGL 驱动（不适用于 NixOS）
      ldconfig = false;
      # 是否通过 WSL 挂载 /etc/fstab，通常 systemd 已处理
      mountFsTab = false;
      # Windows 驱动器挂载选项
      options = "metadata,uid=1000,gid=100";
      # Windows 驱动器挂载根目录
      root = "/mnt";
    };

    # WSL 启动时执行的命令和 systemd 设置
    boot = {
      # 启动时执行的命令
      command = "echo 'Hello WSL'";
      # 是否使用 systemd 作为 init（禁用可能导致 NixOS 损坏）
      systemd = true;
    };

    # Windows 与 Linux 互操作设置
    interop = {
      # 支持从 Linux shell 运行 Windows 程序
      enabled = true;
      # 是否将 Windows PATH 添加到 PATH
      appendWindowsPath = true;
    };

    # 网络设置
    network = {
      # 是否通过 WSL 生成 /etc/hosts
      generateHosts = true;
      # 是否通过 WSL 生成 /etc/resolv.conf
      generateResolvConf = true;
      # WSL 实例的主机名
      hostname = "${host}";
    };

    # 默认用户设置
    user = {
      # 默认用户执行命令
      default = "${username}";
    };
  };
}
