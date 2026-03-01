{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  domain = "lonerorz.dpdns.org";

  hostServices = {
    router = 2026; # caddy
    uptime = 16937;
    reader = 4396;
    share = 14278;
  };

  k8sServices = [
    # "uptime"
    "apps"
  ];
in
{
  environment.systemPackages = with pkgs; [
    cloudflared
  ];

  services.cloudflared = {
    enable = true;
    # certificateFile = config.sops.secrets."cloudflared/cert_pem".path; # cloudflared 登录凭证文件
    tunnels.laptop = {
      credentialsFile = config.sops.secrets."cloudflared/tunnel_json".path; # tunnel ID 凭证
      ingress =
        # Podman / Host
        (lib.mapAttrs' (name: port: {
          name = "${name}.${domain}";
          value = {
            service = "http://127.0.0.1:${toString port}";
          };
        }) hostServices)
        //
          # Kubernetes
          (lib.listToAttrs (
            map (name: {
              name = "${name}.${domain}";
              value = {
                service = "http://127.0.0.1:31247";
              };
            }) k8sServices
          ));
      default = "http_status:404";
    };
  };
}
