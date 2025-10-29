{
  services.battery-manager = {
    enable = true;
    group = "wheel";
    battery-paths = [
      "/tmp/battery-test/BAT0_end_threshold"
      "/tmp/battery-test/BAT1_end_threshold"
    ];
  };
}
