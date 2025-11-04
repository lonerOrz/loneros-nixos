{
  pkgs,
  ...
}:
{
  services.tailscale.enable = true;

  environment.systemPackages = [
    pkgs.tailscale
  ];
}
