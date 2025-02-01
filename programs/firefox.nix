{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [ 
    # firefox_nightly
    firefox
  ];
}
