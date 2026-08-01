{ config, ... }:

{
  name = "forgejo";

  enable = config.virtualisation.quadlet.containers or { } ? forgejo;

  secrets = {
    "forgejo/token" = {
      mode = "0400";
    };
    "forgejo/uuid" = {
      mode = "0600";
    };
  };
}
