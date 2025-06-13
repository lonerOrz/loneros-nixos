{ pkgs, ... }:
{
  # Extra Logitech Support
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # 扫描仪驱动程序
  #hardware.sane = {
  #  enable = true;
  #  extraBackends = [ pkgs.sane-airscan ];
  #  disabledDefaultBackends = [ "escl" ];
  #};

  services = {
    # 系统启动时控制 RGB 灯光效果
    hardware.openrgb = {
      enable = true;
      motherboard = "intel";
    };

    # 打印机支持的配置
    # printing = {
    #   enable = false;
    #   drivers = [
    #  pkgs.hplipWithPlugin
    #   ];
    # };

    # 启用 IPP-over-USB 服务，它允许打印机通过 USB 连接使用
    # ipp-usb.enable = true;

    # 局域网内设备发现的服务
    # avahi = {
    #   enable = true;
    #   nssmdns4 = true;
    #   openFirewall = true;
    # };
  };
}
