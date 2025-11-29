{
  imports = [
    # drivers
    ./amd-drivers.nix
    ./nvidia-drivers.nix
    ./nvidia-prime-drivers.nix
    ./intel-drivers.nix
    ./vm-guest-services.nix
    ./local-hardware-clock.nix

    # other modules
    ./battery.nix
    ./tumbler.nix
    # ./mihomo.nix
  ];
}
