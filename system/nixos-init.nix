{
  system = {
    nixos-init.enable = true;
    etc.overlay.enable = true;
  };
  boot.initrd.systemd.enable = true; # stage1 使用 systemd, 以后 nixos-init 负责 declarative stage 2 activation
  services.userborn.enable = true; # 如果设置root on tmpfs，需要持久化/etc/passwd、/etc/shadow、/etc/group
}
