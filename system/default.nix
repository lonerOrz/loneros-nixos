{
  imports = [
    ./bluetooth.nix
    ./nix.nix
    ./boot.nix
    ./networking.nix
    ./xdg-portal.nix
    ./pipewire.nix
    ./security.nix
    # ./sddm.nix
    ./greet.nix
    ./hardware.nix
    ./timezone.nix
    ./fonts.nix
    ./optimization.nix
    ./doc.nix # 加快 mandb 的构建
  ];
}
