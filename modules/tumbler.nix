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
    environment.systemPackages = with pkgs.xfce; [
      tumbler
    ];

    # 注册 D-Bus 支持
    services.dbus.packages = with pkgs.xfce; [ tumbler ];

    services.udisks2 = {
      enable = true;
      settings = lib.mkIf config.zramSwap.enable {
        "udisks2.conf" = {
          udisks2 = {
            ignore_devices = [
              "/dev/zram0" # 忽略 zram 设备，防止系统卡顿
            ];
          };
        };
      };
    };
    services.gvfs.enable = true;
  };

  meta = {
    maintainers = [ lib.maintainers.lonerOrz ];
  };
}
