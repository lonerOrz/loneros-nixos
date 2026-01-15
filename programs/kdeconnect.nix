{
  pkgs,
  ...
}:
{
  programs.kdeconnect = {
    enable = true;
    # package = pkgs.gnomeExtensions.gsconnect; # Gnome
  };

  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
}
