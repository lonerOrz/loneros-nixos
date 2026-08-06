{
  pkgs,
  modulesPath,
  host,
  username,
  ...
}:

{
  imports = [
    # (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    (if builtins.pathExists ./hardware.nix then ./hardware.nix else { })
    ./disko.nix
    ./persist.nix
    ./users.nix
    ./nix.nix
  ];

  boot = {
    # Resume target for hibernation
    resumeDevice = "/dev/disk/by-label/nixos";

    kernelParams = [
      # Disable kernel audit logging
      "audit=0"

      # Predictable interface names (e.g. eth0 instead of enp1s0)
      # "net.ifnames=0"

      # Hibernation offset (get via: sudo btrfs inspect-internal map-swapfile /swap/swapfile)
      "resume_offset=533760"
    ];

    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;
    };

    # systemd-boot
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    nerd-fonts.jetbrains-mono # unstable
    nerd-fonts.fira-code # unstable
    lxgw-wenkai
    maple-mono.NF-CN
  ];

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking & SSH
  networking.hostName = "${host}";
  services.openssh = {
    enable = true;
    settings = {
      LogLevel = "DEBUG";
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };

    # Persistent host keys (conditional on first boot since they may not exist)
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    # Performance tuning
    extraConfig = ''

      ClientAliveInterval 60
      ClientAliveCountMax 3
      MaxAuthTries 3
      MaxSessions 10
    '';
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false; # disable firewall

  # Security
  # Allow passwordless sudo for user
  security.sudo = {
    enable = true;
    package = pkgs.sudo;
    extraRules = [
      {
        users = [ "${username}" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?
}
