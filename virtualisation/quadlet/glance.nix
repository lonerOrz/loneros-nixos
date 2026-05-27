{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  containerRoot = "${home}/containers";
  glanceRoot = "${containerRoot}/glance";
  podmanSock = "/run/user/${toString uid}/podman/podman.sock";
in
{
  virtualisation.quadlet.containers.glance = {
    rootlessConfig.uid = uid;

    containerConfig = {
      name = "glance";
      image = "docker.io/glanceapp/glance";

      volumes = [
        "${glanceRoot}/config:/app/config"
        "${glanceRoot}/assets:/app/assets"
        "${podmanSock}:/run/docker.sock:ro"
      ];

      publishPorts = [
        "18900:8080"
      ];

      dns = [
        "114.114.114.114"
        "8.8.8.8"
      ];

      environmentFiles = [
        "${glanceRoot}/.env"
      ];

      labels = {
        "io.containers.autoupdate" = "registry";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${containerRoot} 0755 ${username} users -"
    "d ${glanceRoot} 0755 ${username} users -"
    "d ${glanceRoot}/config 0755 ${username} users -"
    "d ${glanceRoot}/assets 0755 ${username} users -"
  ];
}
