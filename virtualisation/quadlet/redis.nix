{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  containerRoot = "${home}/containers";
  redisRoot = "${containerRoot}/redis";
in
{
  virtualisation.quadlet.containers.redis = {
    rootlessConfig.uid = uid;

    containerConfig = {
      name = "redis";
      image = "docker.io/redis:latest";

      publishPorts = [
        "6379:6379"
      ];

      volumes = [
        "${redisRoot}/config/redis.conf:/usr/local/etc/redis/redis.conf"
        "${redisRoot}/data:/data"
      ];

      exec = "redis-server /usr/local/etc/redis/redis.conf";

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
    "d ${redisRoot} 0755 ${username} users -"
    "d ${redisRoot}/config 0755 ${username} users -"
    "d ${redisRoot}/data 0755 ${username} users -"
    "f ${redisRoot}/config/redis.conf 0644 ${username} users -"
  ];
}
