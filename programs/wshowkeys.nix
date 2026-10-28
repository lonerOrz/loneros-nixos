{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [ wshowkeys ];
  programs.wshowkeys.enable = true;
}
