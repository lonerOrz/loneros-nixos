{ options
, host
, stable
, ...
}:
{
  environment.systemPackages = with stable; [
    networkmanagerapplet # GNOME 桌面环境的 NetworkManager 图形化客户端
  ];

  # networking
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.hostName = "${host}";
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  networking.enableIPv6 = true;

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
