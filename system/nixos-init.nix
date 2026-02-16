{
  # 先决条件
  # 1. systemd initrd — nixos-init 基于 systemd service 机制
  # 2. etc overlay — nixos-init 依赖 bootspec 提供的 etc 路径信息
  # 3. userborn/sysusers — 替代传统的 activationScripts 用户管理
  # 4. 禁用 postBootCommands — nixos-init 遵循"最小工作"原则，不在 initrd 执行多余命令
  # 5. 禁用 powerUpCommands — 同上，电源管理命令应该在 systemd 服务中执行
  system = {
    nixos-init.enable = true;
    etc.overlay = {
      enable = true;
      mutable = true;
    };
  };
  boot.initrd.systemd.enable = true; # stage1 使用 systemd, 以后 nixos-init 负责 declarative stage 2 activation
  services.userborn.enable = true; # 如果设置root on tmpfs，需要持久化/etc/passwd、/etc/shadow、/etc/group
}
