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
    # 安装 tumbler 包
    environment.systemPackages = with pkgs.xfce; [ tumbler ];

    # 安装 D-Bus 支持
    services.dbus.packages = with pkgs.xfce; [ tumbler ];

    # 让 user session 启动 tumblerd
    systemd.user.services.tumblerd = {
      description = "Thumbnailing service (tumblerd)";
      after = [
        "dbus.service"
        "gvfs-daemon.service"
      ];
      serviceConfig.ExecStart = "${pkgs.xfce.tumbler}/lib/tumbler-1/tumblerd";
      serviceConfig.Restart = "on-failure";
      wantedBy = [ "default.target" ];
    };

    services.udisks2.enable = true;
    services.gvfs.enable = true;
  };

  meta = {
    maintainers = [ lib.maintainers.lonerOrz ];
  };
}
