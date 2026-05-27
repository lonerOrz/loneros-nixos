{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  containerRoot = "${home}/containers";
  uptimeKumaRoot = "${containerRoot}/uptime-kuma";
  podmanSock = "/run/user/${toString uid}/podman/podman.sock";
in
{
  virtualisation.quadlet.containers.uptime-kuma = {
    rootlessConfig.uid = uid;

    containerConfig = {
      name = "uptime-kuma";
      image = "docker.io/louislam/uptime-kuma:2";

      volumes = [
        "${uptimeKumaRoot}/data:/app/data"
        "${podmanSock}:/var/run/docker.sock"
      ];

      publishPorts = [
        "16937:3001"
      ];

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
    "d ${uptimeKumaRoot} 0755 ${username} users -"
    "d ${uptimeKumaRoot}/data 0755 ${username} users -"
  ];
}
