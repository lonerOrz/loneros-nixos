{
  pkgs,
  stable,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vesktop
  ];
}
