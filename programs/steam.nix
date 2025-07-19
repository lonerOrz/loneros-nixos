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
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
      };
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
