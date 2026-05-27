{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  containerRoot = "${home}/containers";
  filegatorRoot = "${containerRoot}/filegator";
in
{
  virtualisation.quadlet.containers.filegator = {
    rootlessConfig.uid = uid;

    containerConfig = {
      name = "filegator";
      image = "docker.io/filegator/filegator:latest";

      publishPorts = [
        "14278:8080"
      ];

      seccompProfile = "unconfined";

      volumes = [
        "${filegatorRoot}/files:/var/www/filegator/repository:rw"
        "${filegatorRoot}/users.json:/var/www/filegator/private/users.json:rw"
        "${filegatorRoot}/configuration.php:/var/www/filegator/configuration.php:rw"
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
    "d ${filegatorRoot} 0755 ${username} users -"
    "d ${filegatorRoot}/files 0755 ${username} users -"
    "f ${filegatorRoot}/users.json 0644 ${username} users -"
    "f ${filegatorRoot}/configuration.php 0644 ${username} users -"
  ];
}
