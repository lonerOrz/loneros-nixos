{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.preservation.nixosModules.default
  ];

  boot.initrd.systemd.enable = true;

  environment.systemPackages = [
    pkgs.ncdu
  ];

  preservation = {
    enable = true;

    preserveAt."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"

        # System state
        "/var/lib/systemd/coredump"
        "/var/lib/nixos" # UID/GID mappings
        {
          directory = "/var/lib/private";
          mode = "0700";
        }

        # Containers
        "/var/lib/docker"
        "/var/lib/cni"
        "/var/lib/containers"

        # Virtualization
        "/var/lib/libvirt"
        "/var/lib/lxc"
        "/var/lib/lxd"
        "/var/lib/qemu"
        "/var/lib/waydroid"

        # Network & Bluetooth
        "/var/lib/tailscale"
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
        "/var/lib/iwd"
      ];

      files = [
        # Machine ID
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }

        # SSH host keys
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          mode = "0600";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          mode = "0600";
          configureParent = true;
        }
      ];
    };
  };

  # Commit machine-id to /persist
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persist/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persist"
    ];
  };
}
