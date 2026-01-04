{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

let
  cfg = config.services.tumbler;
in
{
  disabledModules = [ (modulesPath + "/services/desktops/tumbler.nix") ];

  options = {
    services.tumbler = {
      enable = lib.mkEnableOption "Tumbler, A D-Bus thumbnailer service";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.tumbler
    ];

    # 注册 D-Bus 支持
    services.dbus.packages = [ pkgs.tumbler ];

    services.gvfs.enable = true;
  };

  meta = {
    maintainers = [ lib.maintainers.lonerOrz ];
  };
}
