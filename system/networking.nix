{
  host,
  stable,
  options,
  ...
}:
{
  environment.systemPackages = with stable; [
    networkmanagerapplet # GNOME 桌面环境的 NetworkManager 图形化客户端
    dig # 域名服务器
  ];

  programs = {
    mtr.enable = true; # 网络诊断工具
    nm-applet.indicator = true; # NetworkManager 图形界面工具
  };

  networking = {
    hostName = "${host}";
    enableIPv6 = true;
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    networkmanager = {
      enable = true;
      dns = "systemd-resolved"; # one of "default", "dnsmasq", "systemd-resolved", "none"
    };
    hosts = {
      # 本机基础配置
      "127.0.0.1" = [ "localhost" ];
      "::1" = [ "localhost" ];
      # 黑名单域名
      "0.0.0.0" = [
        "qqpatch.gtimg.cn" # 阻止 QQ 自动更新
      ];
    };
  };

  # DNS 解析服务
  services.resolved = {
    enable = true;
    dnssec = "false"; # allow-downgrade
    dnsovertls = "opportunistic";
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
      "114.114.114.114"
      "218.6.200.139"
      "61.139.2.69"
      "2606:4700:4700::1111" # Cloudflare IPv6
      "2001:4860:4860::8888" # Google IPv6
      "240c::6666" # 114DNS IPv6
      "2400:3200::1" # 阿里DNS IPv6
      "192.168.100.1"
      "192.168.2.1"
    ];
    extraConfig = ''
      CacheTTLSec=3600
      DNSStubListener=yes
    '';
  };
}
