{
  lib,
  pkgs,
  username,
  ...
}:
{
  # services.mihomo = {
  #   enable = true;
  #   configFile = "/home/${username}/.config/mihomo/config.yaml"; # 需要自己写配置
  #   webui = pkgs.metacubexd; # clash-dashboard yacd metacubexd
  #   tunMode = true;
  # };
  # mihomo-party-wrapper
  environment.systemPackages = with pkgs; [
    mihomo-party-wrapper
  ];
  security.wrappers.mihomo-party = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_bind_service,cap_net_admin=+ep";
    source = "${lib.getExe pkgs.mihomo-party-wrapper}";
  };
}
