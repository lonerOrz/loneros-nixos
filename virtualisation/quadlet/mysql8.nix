{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  containerRoot = "${home}/containers";
  mysqlRoot = "${containerRoot}/mysql";
in
{
  virtualisation.quadlet.containers.mysql = {
    rootlessConfig.uid = uid;

    containerConfig = {
      name = "mysql8";
      image = "registry.cn-hangzhou.aliyuncs.com/zhengqing/mysql:8.0";

      volumes = [
        "${mysqlRoot}/my.cnf:/etc/mysql/my.cnf"
        "${mysqlRoot}/data:/var/lib/mysql"
        "${mysqlRoot}/mysql-files:/var/lib/mysql-files"
      ];

      environments = {
        TZ = "Asia/Shanghai";
        LANG = "en_US.UTF-8";
        MYSQL_ROOT_PASSWORD = "root";
        MYSQL_DATABASE = "loner-demo";
      };

      user = "root";
      publishPorts = [ "3308:3306" ];

      podmanArgs = [ "--privileged" ];

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
    "d ${mysqlRoot} 0755 ${username} users -"
    "d ${mysqlRoot}/data 0700 ${username} users -"
    "d ${mysqlRoot}/mysql-files 0750 ${username} users -"
    "f ${mysqlRoot}/my.cnf 0644 ${username} users -"
  ];
}
