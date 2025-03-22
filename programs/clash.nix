{
  pkgs,
  ...
}:
{
  # 系统代理模式没用，tun创建的虚拟网卡很不稳定，甚至创建不出来，所以弃用，但配置留在这
  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev; # or clash-nyanpasu (is break!!!)
    autoStart = true;
  };
}
