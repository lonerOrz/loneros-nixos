{
  config,
  username,
  ...
}:

let
  uid = config.users.users.${username}.uid;
  home = config.users.users.${username}.home;
  root = "${home}/containers/hermes";
in
{
  virtualisation.quadlet = {
    autoUpdate = {
      enable = true;
      calendar = "daily";
    };

    networks.hermes-net = {
      autoStart = true;
      rootlessConfig.uid = uid;
    };

    containers.hermes = {
      autoStart = true;

      rootlessConfig.uid = uid;

      containerConfig = {
        name = "hermes";

        image = "docker.io/nousresearch/hermes-agent:latest";

        networks = [ "hermes-net.network" ];

        userns = "keep-id";

        exec = "gateway run";

        publishPorts = [
          "8642:8642"
        ];

        # environments = {
        #   ANTHROPIC_API_KEY = "your_key";
        #   OPENAI_API_KEY = "your_key";
        #   TELEGRAM_BOT_TOKEN = "your_token";
        # };

        volumes = [
          "${root}/data:/opt/data"
        ];

        healthCmd = "curl -f http://localhost:8642/health";
        healthInterval = "10s";
        healthTimeout = "5s";
        healthRetries = 10;
        healthStartPeriod = "10s";

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

    containers.hermes-dashboard = {
      autoStart = true;

      rootlessConfig.uid = uid;

      containerConfig = {
        name = "hermes-dashboard";

        image = "docker.io/nousresearch/hermes-agent:latest";

        networks = [ "hermes-net.network" ];

        userns = "keep-id";

        exec = "dashboard --host 0.0.0.0 --insecure";

        publishPorts = [
          "9119:9119"
        ];

        environments = {
          # 处于同一自定义网络下，恢复使用服务名称 "hermes" 进行跨容器通信
          GATEWAY_HEALTH_URL = "http://hermes:8642";
        };

        volumes = [
          "${root}/data:/opt/data"
        ];

        healthCmd = "curl -f http://localhost:9119";
        healthInterval = "10s";
        healthTimeout = "5s";
        healthRetries = 10;
        healthStartPeriod = "10s";

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
    "d ${root}/data 0755 ${username} users -"
  ];
}
