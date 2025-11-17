{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    radicle-node
    radicle-httpd
    radicle-desktop
    radicle-tui
  ];
}
