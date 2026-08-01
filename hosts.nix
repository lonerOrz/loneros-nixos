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

  # 临时环境（root on tmpfs）
  bootstrap = {
    system = "x86_64-linux";
    username = "loner";
  };
}
