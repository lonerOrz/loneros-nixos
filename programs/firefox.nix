{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # firefox
    # firefox_nightly

    # zen
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight # default beta twilight
  ];
}
