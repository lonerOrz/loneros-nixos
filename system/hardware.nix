{
  # Extra Logitech Support
  hardware.logitech.wireless.enable = false;
  hardware.logitech.wireless.enableGraphical = false;

  # OpenGL
  hardware.graphics = {
    enable = true;
  };

  # 扫描仪驱动程序
  #hardware.sane = {
  #  enable = true;
  #  extraBackends = [ pkgs.sane-airscan ];
  #  disabledDefaultBackends = [ "escl" ];
  #};

  # 系统启动时控制 RGB 灯光效果
  services = {
    hardware.openrgb.enable = true;
    hardware.openrgb.motherboard = "intel";
  };

}
