{
  username,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    # jellyfin-tui
    # jellyfin-rpc
    # jellyfin-mpv-shim
  ];

  services.jellyfin = {
    enable = true;
    user = "${username}"; # 允许它看到这些外部驱动器挂载的最简单方法是更改服务的用户 sudo chown -R /var/lib/jellyfin
    openFirewall = true;
  };

  users.users.${username}.extraGroups = [ "jellyfin" ]; # 将用户添加到 jellyfin 组
}
