{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    mpv
    mpv-handler
  ];
}
