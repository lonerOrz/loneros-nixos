{
  config,
  username,
  lib,
  ...
}:
let
  k3sEnabled = config.cluster.k3s.enable;
in
{
  services.rpcbind.enable = true;
  services.nfs = {
    server = {
      enable = true;
      exports = ''
        /home/${username}/Downloads *(rw,sync,no_subtree_check,no_root_squash,insecure)
      ''
      + lib.optionalString k3sEnabled ''
        /var/lib/k3s-nfs *(rw,sync,no_subtree_check,no_root_squash,insecure)
      '';
      nproc = 16; # 限制最大线程数
      lockdPort = 32765;
      mountdPort = 32766;
      statdPort = 32767;
      createMountPoints = true; # 启动时自动创建 exports 中列出的目录（如果它们不存在）
    };
    settings = {
      mountd.manage-gids = true;
    };
  };

  # Limit shutdown time of NFS server to avoid blocking system shutdown
  # when clients (e.g. k3s pods) still hold NFS volumes.
  systemd.services.nfs-server.serviceConfig = lib.mkIf k3sEnabled {
    TimeoutStopSec = "15s";
    KillMode = "mixed";
  };
}
