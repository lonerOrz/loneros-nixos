{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  readerRoot = "${home}/containers/reader";
in
{
  virtualisation.quadlet = {
    autoUpdate = {
      enable = true;
      calendar = "daily";
    };

    pods.reader-pod = {
      autoStart = true;
      rootlessConfig.uid = uid;
      podConfig = {
        name = "reader-pod";
        publishPorts = [
          "4396:8080"
          "8050:8050"
        ];
      };
    };

    containers.reader = {
      autoStart = true;
      rootlessConfig.uid = uid;
      containerConfig = {
        name = "reader";
        image = "docker.io/hectorqin/reader:latest";
        pod = "reader-pod.pod";

        environments = {
          SPRING_PROFILES_ACTIVE = "prod";
          READER_APP_USERLIMIT = "50";
          READER_APP_USERBOOKLIMIT = "200";
          READER_APP_CACHECHAPTERCONTENT = "true";
          READER_APP_SECURE = "true";
          READER_APP_SECUREKEY = "123456";
        };

        volumes = [
          "${readerRoot}/logs:/logs"
          "${readerRoot}/storage:/storage"
        ];

        autoUpdate = "registry";
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "5s";
      };
    };

    # 如果启用远程webview，取消下面注释
    /*
      containers.remote-webview = {
        autoStart = true;
        rootlessConfig.uid = uid;
        containerConfig = {
          name = "remote-webview";
          image = "docker.io/hectorqin/remote-webview";
          pod = "reader-pod.pod";
          autoUpdate = "registry";
        };
        serviceConfig = {
          Restart = "always";
          RestartSec = "5s";
        };
      };
    */
  };

  systemd.tmpfiles.rules = [
    "d ${readerRoot} 0755 ${username} users -"
    "d ${readerRoot}/logs 0755 ${username} users -"
    "d ${readerRoot}/storage 0755 ${username} users -"
  ];
}
