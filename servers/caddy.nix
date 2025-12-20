{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  portH2 = "2026";
  portH3 = "2026";
in
{
  environment.systemPackages = with pkgs; [
    caddy
  ];

  services.caddy = {
    enable = true;
    enableReload = true;

    settings = {
      apps = {
        # HTTP
        http = {
          servers = {
            internal = {
              listen = [
                ":2026"
                # not work
                # "fdname/caddy-h2"
                # "fdgramname/caddy-h3"
              ];
              routes = [
                {
                  "match" = [
                    {
                      "path" = [ "/*" ];
                    }
                  ];
                  handle = [
                    {
                      handler = "reverse_proxy";
                      upstreams = [
                        {
                          dial = "127.0.0.1:16937";
                        }
                      ];
                    }
                  ];
                }
              ];
            };
          };
        };
      };

    };
  };

  systemd.sockets.caddy-h2 = {
    socketConfig = {
      ListenStream = [ "${portH2}" ]; # TCP
      Service = "caddy.service";
    };
    wantedBy = [ "sockets.target" ];
  };

  systemd.sockets.caddy-h3 = {
    socketConfig = {
      ListenDatagram = [ "${portH3}" ]; # UDP
      Service = "caddy.service";
    };
    wantedBy = [ "sockets.target" ];
  };
}
