{
  inputs,
  pkgs,
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
        "/etc/nix/inputs"
        # "/etc/agenix" # age 密钥

        # 系统核心状态
        "/var/lib/nixos"
        "/var/lib/systemd"
        {
          directory = "/var/lib/private";
          mode = "0700";
        }

        # 容器
        # "/var/lib/docker"
        "/var/lib/cni"
        "/var/lib/containers"

        # flatpak
        # "/var/lib/flatpak" # 强制使用用户级别的 flatpak

        # 虚拟化
        "/var/lib/incus"
        # "/var/lib/libvirt"
        # "/var/lib/lxc"
        # "/var/lib/lxd"
        "/var/lib/qemu"
        # "/var/lib/waydroid"

        # 网络
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
        "/var/lib/iwd"
        "/var/lib/tailscale"
        "/var/lib/nfs"
      ];

      files = [
        # 自动生成的机器 ID
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        # https://nix-community.github.io/preservation/impermanence-migration.html#handling-of-existing-state
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }
      ];
    };
  };

  # 抑制默认的 machine-id 提交服务
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # 将生成的 machine-id 提交至持久化位置 /persist
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

  # 在 initrd 阶段同样屏蔽此服务以避免报错 [3.1.4, 3.4.6]
  boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
}
