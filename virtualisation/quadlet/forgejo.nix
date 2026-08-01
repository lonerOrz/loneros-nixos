{
  pkgs,
  config,
  username,
  ...
}:

let
  web-port = "13000";
  ssh-port = "13022";
  domain = "localhost";

  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  forgejoRoot = "${home}/containers/forgejo";
  podmanSock = "/run/user/${toString uid}/podman/podman.sock";
in
{
  # runner config
  sops.templates."forgejo-runner-config.yaml" = {
    owner = "${username}";
    mode = "0600";
    content = builtins.readFile (
      (pkgs.formats.yaml { }).generate "forgejo-runner-raw.yaml" {
        log = {
          level = "info";
        };

        server = {
          connections = {
            forgejo = {
              url = "http://forgejo:3000";
              uuid = config.sops.placeholder."forgejo/uuid";
              token = config.sops.placeholder."forgejo/token";
            };
          };
        };

        runner = {
          capacity = 1;
          timeout = "6h";
          envs = {
            DOCKER_HOST = "unix:///var/run/docker.sock";
            GIT_CONFIG_COUNT = "1";
            GIT_CONFIG_KEY_0 = "http.version";
            GIT_CONFIG_VALUE_0 = "HTTP/1.1";
          };
          labels = [
            "docker:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
            "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
          ];
        };

        cache = {
          enabled = true;
          dir = "/data/cache";
        };

        container = {
          network = "forgejo-net";
          docker_host = "-";
          privileged = true;
        };
      }
    );
  };

  # Quadlet containers
  virtualisation.quadlet = {
    autoUpdate = {
      enable = true;
      calendar = "daily";
    };

    # Network
    networks.forgejo-net = {
      autoStart = true;
      rootlessConfig.uid = uid;
    };

    # Volume
    volumes.forgejo-data = {
      autoStart = true;
      rootlessConfig.uid = uid;
    };

    # Forgejo main service
    containers.forgejo = {
      autoStart = true;
      rootlessConfig.uid = uid;

      containerConfig = {
        name = "forgejo";
        image = "codeberg.org/forgejo/forgejo:16-rootless";

        networks = [ "forgejo-net.network" ];

        publishPorts = [
          "${web-port}:3000"
          "${ssh-port}:2222"
        ];

        environments = {
          FORGEJO__server__DOMAIN = domain;
          FORGEJO__server__ROOT_URL = "http://${domain}:${web-port}/";
          FORGEJO__server__HTTP_PORT = "3000";
          FORGEJO__server__SSH_PORT = ssh-port;
          FORGEJO__server__SSH_LISTEN_PORT = "2222";

          FORGEJO__actions__ENABLED = "true";
          FORGEJO__actions__DEFAULT_ACTIONS_URL = "https://ghproxy.net/https://github.com";
          FORGEJO__database__DB_TYPE = "sqlite3";
          FORGEJO__database__PATH = "/var/lib/gitea/forgejo.db";

          FORGEJO__migrations__ALLOW_LOCALNETWORKS = "true";
          FORGEJO__migrations__ALLOWED_DOMAINS = "*";
        };

        volumes = [
          "forgejo-data.volume:/var/lib/gitea"
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

    # Forgejo runner service
    containers.forgejo-runner = {
      autoStart = true;
      rootlessConfig.uid = uid;

      containerConfig = {
        name = "forgejo-runner";
        image = "data.forgejo.org/forgejo/runner:12";
        userns = "keep-id";

        networks = [ "forgejo-net.network" ];

        environments = {
          DOCKER_HOST = "unix:///var/run/docker.sock";
          GIT_CONFIG_COUNT = "1";
          GIT_CONFIG_KEY_0 = "http.version";
          GIT_CONFIG_VALUE_0 = "HTTP/1.1";
        };

        exec = "forgejo-runner daemon --config /config.yaml";

        volumes = [
          "${forgejoRoot}/runner-data:/data"
          "${config.sops.templates."forgejo-runner-config.yaml".path}:/config.yaml"
          "${podmanSock}:/var/run/docker.sock"
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
  };

  systemd.tmpfiles.rules = [
    "d ${forgejoRoot} 0755 ${username} users -"
    "d ${forgejoRoot}/runner-data 0755 ${username} users -"
  ];
}
