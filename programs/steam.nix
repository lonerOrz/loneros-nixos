{
  config,
  pkgs,
  ...
}:
{
  # Needed For Some Steam Games
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
  };
}
