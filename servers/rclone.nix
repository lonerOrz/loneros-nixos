{
  config,
  pkgs,
  username,
  ...
}:
let
  mountPoint = "/mnt/webdav/";
in
{
  environment.systemPackages = with pkgs; [ rclone ];
  users.users.${username}.extraGroups = [ "fuse" ]; # 将用户添加到 fuse 组

  systemd.services.rclone = {
    enable = true;
    description = "rclone mount webdav";
    after = [ "network-online.target" ];
    wantedBy = [ "default.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      # User = "loner";
      # Group = "fuse";
      # 将标准输出（stdout）和 错误输出（stderr）追加到日志文件 /var/log/rclone.log 中
      StandardOutput = "append:/var/log/rclone.log";
      StandardError = "append:/var/log/rclone.log";
      # 当服务因为错误退出时自动重启
      Restart = "on-failure";
      RestartSec = "10s";

      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount alist:/ ${mountPoint} \
          --vfs-links \
          --no-check-certificate \
          --allow-other \
          --umask 000 \
          --header 'Referer:https://ww.aliyundrive.com/' \
          --config /home/loner/.config/rclone/rclone.conf \
          --vfs-cache-mode full \
          --vfs-cache-max-size 50G \
          --vfs-cache-max-age 72h \
          --dir-cache-time 72h \
          --attr-timeout 30s \
          --poll-interval 0 \
          --vfs-read-chunk-size 128M \
          --vfs-read-chunk-size-limit 1G \
          --vfs-read-ahead 256M \
          --no-modtime \
          --transfers 4 \
          --timeout 1h
      '';
      ExecStop = "${pkgs.util-linux}/bin/umount -l ${mountPoint}";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${mountPoint} 0755 ${username} users -"
  ];
}
