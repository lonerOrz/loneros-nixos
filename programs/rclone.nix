{
  config,
  pkgs,
  username,
  ...
}:
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
        ${pkgs.rclone}/bin/rclone mount alist:/ /home/loner/Videos/webdav \
                --copy-links \
                --no-gzip-encoding \
                --no-check-certificate \
                --allow-other \
                --allow-non-empty \
                --umask 000 \
                --header 'Referer:https://ww.aliyundrive.com/' \
                --config /home/loner/.config/rclone/rclone.conf \
                --use-mmap \
                --dir-cache-time 24h \
                --buffer-size 512M \
                --vfs-cache-mode full \
                --vfs-read-ahead 16M \
                --vfs-read-chunk-size 100M \
                --vfs-read-chunk-size-limit 0 \
                --vfs-cache-max-size 20G
      '';
    };
  };
}
