{ config, ... }:

{
  name = "mihomo";

  enable = config.services.mihomo.enable or false;

  secrets = {
    "mihomo/subscription1" = {
      mode = "0600";
      format = "yaml";
    };
    "mihomo/subscription2" = {
      mode = "0600";
      format = "yaml";
    };
    "mihomo/secret" = {
      mode = "0600";
    };
  };
}
