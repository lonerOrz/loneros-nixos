{
  # laptop
  loneros = {
    system = "x86_64-linux";
    username = "loner";
  };

  # WSL2
  loneros-wsl = {
    system = "x86_64-linux";
    username = "nixos";
  };

  # 远程 VM（快速部署测试）
  remote-vm = {
    system = "x86_64-linux";
    username = "loner";
  };

  # 临时环境（root on tmpfs）
  bootstrap = {
    system = "x86_64-linux";
    username = "loner";
  };
}
