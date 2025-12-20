{
  pkgs,
  config,
  username,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    cloudflared
  ];

  services.cloudflared = {
    enable = true;
    # certificateFile = config.sops.secrets."cloudflared/cert_pem".path; # cloudflared 登录凭证文件
    tunnels.laptop = {
      credentialsFile = config.sops.secrets."cloudflared/tunnel_json".path; # tunnel ID 凭证
      ingress = {
        "router.lonerorz.dpdns.org" = {
          service = "http://127.0.0.1:2026";
        };
      };
      default = "http_status:404";
    };
  };
}
