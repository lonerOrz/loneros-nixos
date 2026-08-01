{ config, ... }:

{
  name = "cloudflared";

  enable = config.services.cloudflared.enable or false;

  secrets = {
    "cloudflared/cert_pem" = {
      mode = "0600";
    };
    "cloudflared/tunnel_json" = {
      mode = "0600";
    };
  };
}
