{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    pamixer # 命令行音量控制工具
    pavucontrol # 图形化音频控制工具
    playerctl # 控制支持 MPRIS 协议的音频和视频播放器的播放行为
  ];

  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true; # PulseAudio 兼容层,产生.pulse-cookie文件
      wireplumber = {
        enable = true;
        extraConfig = {
          "10-disable-camera" = {
            "wireplumber.profiles" = {
              main."monitor.libcamera" = "disabled";
            };
          };
        };
      };
    };
  };
}
