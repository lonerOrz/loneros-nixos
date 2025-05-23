{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # firefox
    firefox_nightly

    # zen
    inputs.zen-browser.packages."${system}".twilight # default beta twilight
  ];
}
