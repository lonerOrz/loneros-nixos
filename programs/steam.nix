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

  environment.systemPackages = with pkgs; [ mangohud ];

  programs = {
    gamemode.enable = true;
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            freetype
            SDL2
            dbus
            glib
          ];

        extraLibraries =
          pkgs: with pkgs; [
            alsa-lib
          ];
        extraProfile = ''
          export PROTON_LOG=1
          export STEAM_FRAME_FORCE_CLOSE=1
        '';
        # clear $HOME
        extraBwrapArgs = [
          "--bind $HOME/.config/steam $HOME"
        ];
        extraEnv = {
          LD_PRELOAD_32 = "";
        };
        privateTmp = true;
      };
      fontPackages = [ pkgs.wqy_zenhei ];
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
