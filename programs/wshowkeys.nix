{
  config,
  stable,
  ...
}:
{
  environment.systemPackages = with stable; [ wshowkeys ];
  programs.wshowkeys.enable = true;
}
