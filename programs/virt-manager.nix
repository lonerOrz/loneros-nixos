{
  config,
  pkgs,
  username,
  ...
}:
{
  users.groups.libvirtd.members = [ "${username}" ];
  users.groups.kvm.members = [ "${username}" ];

  boot = {
    kernelParams = [
      "intel_iommu=on" # AMD: amd_iommu=no
      "iommu=pt" # 指定 IOMMU 使用 "passthrough" 模式
      # "vfio-pci.ids=10de:1f06,10de:10f9" # 指定要直通的 PCI 设备 ID.利用lspci -nn | grep -i nvidia 查看显卡和音频
    ];
    kernelModules = [
      "kvm-intel" # AMD: kvm-amd
      # VFIO 允许虚拟机直接访问物理设备
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
  };

  environment.systemPackages = with pkgs; [
    qemu_kvm
    virt-manager
    virt-viewer
    libvirt
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    #gnome.adwaita-icon-theme
    # quickemu
    # quickgui # quickemu GUI
    virglrenderer # 3D 加速
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      allowedBridges = [
        "virbr0"
      ];
      qemu = {
        # runAsRoot = true;
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  services.spice-vdagentd.enable = true;

  # 启用 UEFI 固件支持
  systemd.tmpfiles.rules = [
    "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
    "L+ /usr/share/qemu/vars.fd - - - - ${pkgs.qemu}/share/qemu/edk2-i386-vars.fd"
    "L+ /usr/share/qemu/secure-code.fd - - - - ${pkgs.qemu}/share/qemu/edk2-x86_64-secure-code.fd"
  ];

  # 支持模拟的不同架构
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    # "riscv64-linux"
  ];

  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = [ "qemu:///system" ];
  #     uris = [ "qemu:///system" ];
  #   };
  # };

}
