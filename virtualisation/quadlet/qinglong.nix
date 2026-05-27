{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  containerRoot = "${home}/containers";
  qlRoot = "${containerRoot}/qinglong";
in
{
  virtualisation.quadlet.containers.qinglong = {
    rootlessConfig.uid = uid;

    containerConfig = {
      name = "qinglong";
      image = "docker.io/whyour/qinglong:debian";

      volumes = [
        "${qlRoot}/data:/ql/data"
      ];

      publishPorts = [
        "15789:5700"
      ];

      environments = {
        QlBaseUrl = "/";
      };

      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };

    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${containerRoot} 0755 ${username} users -"
    "d ${qlRoot} 0755 ${username} users -"
    "d ${qlRoot}/data 0755 ${username} users -"
  ];
}
