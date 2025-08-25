{
  config,
  pkgs,
  ...
}:
{
  services.sunshine = {
    enable = false;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };

  # Error: Failed to gain CAP_SYS_ADMIN
  # security.wrappers.sunshine = {
  #   owner = "root";
  #   group = "root";
  #   capabilities = "cap_sys_admin+p";
  #   source = "${pkgs.sunshine}/bin/sunshine";
  # };

  # Error: avahi::entry_group_new() failed: Not permitted
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = false; # ⚠️ 改为 false，交给 root 服务发布
  };

  # systemd.user.services.sunshine = {
  #   description = "Sunshine game stream host";
  #   wantedBy = [ "default.target" ];
  #   serviceConfig = {
  #     ExecStart = "/run/wrappers/bin/sunshine";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  # };

  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];

}
