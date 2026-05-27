{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;

  root = "${home}/containers/aria2";

  dnsServers = [
    "8.8.8.8"
    "8.8.4.4"
    "114.114.114.114"
  ];
in
{
  virtualisation.quadlet = {
    autoUpdate = {
      enable = true;
      calendar = "daily";
    };

    pods.aria2 = {
      autoStart = true;

      rootlessConfig.uid = uid;

      podConfig = {
        publishPorts = [
          "6800:6800"
          "6888:6888"
          "6888:6888/udp"
          "9040:6880"
        ];
      };
    };

    containers.aria2-pro = {
      autoStart = true;

      rootlessConfig.uid = uid;

      containerConfig = {
        name = "aria2-pro";

        image = "docker.io/p3terx/aria2-pro";

        pod = "aria2.pod";

        environments = {
          UMASK_SET = "022";
          RPC_SECRET = "123456";
          RPC_PORT = "6800";
          LISTEN_PORT = "6888";
          DISK_CACHE = "64M";
          IPV6_MODE = "false";
          UPDATE_TRACKERS = "true";
          CUSTOM_TRACKER_URL = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt";
          TZ = "Asia/Shanghai";
        };

        volumes = [
          "${root}/config:/config"
          "${root}/downloads:/downloads"
        ];

        dns = dnsServers;

        autoUpdate = "registry";

        logDriver = "json-file";

        logOptions = [
          "max-size=1m"
        ];
      };

      serviceConfig = {
        Restart = "unless-stopped";
      };
    };

    containers.ariang = {
      autoStart = true;

      rootlessConfig.uid = uid;

      containerConfig = {
        name = "ariang";

        image = "docker.io/p3terx/ariang";

        pod = "aria2.pod";

        exec = "--port 6880 --ipv6";

        dns = dnsServers;

        autoUpdate = "registry";

        logDriver = "json-file";

        logOptions = [
          "max-size=1m"
        ];
      };

      serviceConfig = {
        Restart = "unless-stopped";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${root} 0755 ${username} users -"
    "d ${root}/config 0755 ${username} users -"
    "d ${root}/downloads 0755 ${username} users -"
  ];
}
