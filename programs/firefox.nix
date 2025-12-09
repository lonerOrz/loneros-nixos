{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # firefox
    # firefox_nightly # done https://github.com/NixOS/nixpkgs/pull/466490
    inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin

    # zen
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight # default beta twilight
  ];
}
