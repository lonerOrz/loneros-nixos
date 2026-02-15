{
  pkgs,
  inputs,
  username,
  ...
}:
{
  imports = [
    inputs.preservation.nixosModules.default
  ];

  # pverservation required initrd using systemd.
  boot.initrd.systemd.enable = true;

  environment.systemPackages = [
    pkgs.ncdu
  ];

  # If the directory/file already exists in the root filesystem you should
  # NOTE: move those files/directories to /persistent first
  preservation = {
    enable = true;

    preserveAt."/persistent" = {
      # 系统级目录持久化
      directories = [
        "/etc/ssh"
        "/etc/NetworkManager/system-connections"

        # "/etc/secureboot" # lanzaboote - 安全启动

        # "/var/log"
        # system-core
        "/var/lib/systemd/coredump"
        "/var/lib/nixos"
        {
          directory = "/var/lib/private";
          mode = "0700";
        }

        # "/etc/agenix/" # age-nix

        # containers
        "/var/lib/docker"
        "/var/lib/cni"
        "/var/lib/containers"

        # virtualisation
        "/var/lib/libvirt"
        "/var/lib/lxc"
        "/var/lib/lxd"
        "/var/lib/qemu"
        "/var/lib/waydroid"

        # network
        "/var/lib/tailscale"
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
        "/var/lib/iwd"
      ];

      # 系统级文件持久化
      files = [
        # auto-generated machine ID
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];

      # 用户目录持久化
      users.${username} = {
        directories = [
          # XDG directories
          "Downloads"
          "Documents"
          "Pictures"
          "Music"
          "Videos"

          ".ssh" # SSH keys
          ".gnupg" # GPG keys

          ".local/bin"
          ".local/share/keyrings"
          ".local/share/direnv"
          ".config"

          "cps"
        ];
        files = [
          # ".bashrc"
        ];
      };
    };
  };

  # Create some directories with custom permissions.
  # 持久化目录的直接父目录（若非顶层）默认权限为 root:root 0755
  # 用户可能无法在其中创建新文件/目录
  # 因此使用 systemd-tmpfiles 配置正确权限
  # 或设置 configureParent = true
  systemd.tmpfiles.settings.preservation =
    let
      permission = {
        user = username;
        group = "users";
        mode = "0755";
      };
    in
    {
      "/home/${username}/.config".d = permission;
      "/home/${username}/.cache".d = permission;
      "/home/${username}/.local".d = permission;
      "/home/${username}/.local/share".d = permission;
      "/home/${username}/.local/state".d = permission;
    };

  # 禁用默认服务（在临时 root 下会失败）
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  # 将 machine-id 提交到持久化分区
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
}
