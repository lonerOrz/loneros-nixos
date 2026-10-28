{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vesktop
  ];
}
