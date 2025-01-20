{
  config,
  pkgs,
  username,
  ...
}:
{
  #programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["${username}"];
  users.groups.kvm.members = ["${username}"];

  boot = {
    kernelParams = [
      "intel_iommu=on" # AMD: amd_iommu=no
      "iommu=pt" # 指定 IOMMU 使用 "passthrough" 模式
      # "vfio-pci.ids=10de:1f06,10de:10f9" # 指定要直通的 PCI 设备 ID.利用lspci -nn | grep -i nvidia 查看显卡和音频
    ];
    kernelModules = [
      "kvm-intel"
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
    win-virtio
    win-spice
    #gnome.adwaita-icon-theme
    quickemu
  ];
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  
  services.spice-vdagentd.enable = true;

  # 启用 UEFI 固件支持
  systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

  # 支持模拟的不同架构
  # boot.binfmt.emulatedSystems = [
  #   "aarch64-linux"
  #   "riscv64-linux"
  # ];

  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = [ "qemu:///system" ];
  #     uris = [ "qemu:///system" ];
  #   };
  # };

}
