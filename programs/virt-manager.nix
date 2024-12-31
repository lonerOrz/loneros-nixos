{
  config,
  pkgs,
  username,
  ...
}:
{
  #programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["${username}"];
  
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

  #dconf.settings = {
  #  "org/virt-manager/virt-manager/connections" = {
  #    autoconnect = [ "qemu:///system" ];
  #    uris = [ "qemu:///system" ];
  #  };
  #};

}
