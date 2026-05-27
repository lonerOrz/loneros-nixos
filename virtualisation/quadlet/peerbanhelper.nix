{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;

  root = "${home}/containers/peerbanhelper";
in
{
  virtualisation.quadlet.containers.peerbanhelper = {
    autoStart = true;

    rootlessConfig.uid = uid;

    containerConfig = {
      name = "peerbanhelper";

      image = "registry.cn-hangzhou.aliyuncs.com/ghostchu/peerbanhelper:latest";

      environments = {
        PUID = "0";
        PGID = "0";
        TZ = "Asia/Shanghai";
      };

      volumes = [
        "${root}/data:/app/data"
      ];

      dns = [
        "8.8.8.8"
        "114.114.114.114"
      ];

      podmanArgs = [
        "--network=host"
      ];

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

  systemd.tmpfiles.rules = [
    "d ${root} 0755 ${username} users -"
    "d ${root}/data 0755 ${username} users -"
  ];
}
