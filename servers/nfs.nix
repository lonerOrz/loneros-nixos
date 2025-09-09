{
  config,
  username,
  pkgs,
  ...
}:
{
  services.rpcbind.enable = true;

  services.nfs = {
    server = {
      enable = true;
      # 导出你要分享的目录
      exports = ''
        /home/${username}/Downloads *(rw,sync,no_subtree_check,no_root_squash,insecure)
        /home/${username}/cps/xunlei/dls *(rw,sync,no_subtree_check,no_root_squash,insecure)
        /home/${username}/cps/baidunetdisk/dls *(rw,sync,no_subtree_check,no_root_squash,insecure)
        /home/${username}/cps/aria2/downloads *(rw,sync,no_subtree_check,no_root_squash,insecure)
      '';
      nproc = 16; # 限制最大线程数
      # 固定端口（适用于 NAT 或有防火墙的情况）
      lockdPort = 32765;
      mountdPort = 32766;
      statdPort = 32767;
      createMountPoints = true; # 启动时自动创建 exports 中列出的目录（如果它们不存在）
    };
    settings = {
      mountd.manage-gids = true;
    };
  };
}
