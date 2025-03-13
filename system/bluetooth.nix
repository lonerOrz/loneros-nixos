{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bluez
    bluez-experimental
    bluez-tools
    bluez-alsa
    blueman
  ];
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };
  services.blueman.enable = true;
}
