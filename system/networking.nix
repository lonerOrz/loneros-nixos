{
  options,
  host,
  ...
}:
{
  # networking
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.hostName = "${host}";
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];

  # DNS 解析服务
  services.resolved = {
    enable = true;
    dnssec = "false";
    dnsovertls = "opportunistic";
    fallbackDns = [
      "8.8.4.4"
      "114.114.114.114"
    ];
  };

}
