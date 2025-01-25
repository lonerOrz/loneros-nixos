{
  pkgs,
  ...
}:
{
  # cachyOS kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  # cachyOS kernel 调度规则
  services.scx = {
    enable = true;
    scheduler = "scx_rusty";
    package = pkgs.scx_git.full;  # 获取github上最新的调度规则
  };

}
