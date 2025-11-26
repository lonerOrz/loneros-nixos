{
  system = {
    nixos-init.enable = true;
    etc.overlay.enable = true;
  };
  boot.initrd.systemd.enable = true;
  services.userborn.enable = true;
}
