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
        "/etc/ssh"
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
        # "/var/lib/flatpak"

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
      ];

      files = [
        # 自动生成的机器 ID
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
    };
  };

  # 抑制默认的 machine-id 提交服务
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # 将生成的 machine-id 提交至持久化位置 /persistent
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };

  # 在 initrd 阶段同样屏蔽此服务以避免报错 [3.1.4, 3.4.6]
  boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
}
