{
  pkgs,
  modulesPath,
  host,
  username,
  ...
}:
let
  inherit (import ./variables.nix) keyboardLayout;
in
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

    # system
    ../../system/timezone.nix
    ../../system/fonts.nix
    ../../system/doc.nix
    ../../system/btrfs.nix
    ../../system/audio.nix
    ../../system/clipboard.nix

    # programs
    ../../programs/direnv.nix
    ../../programs/git.nix
    ../../programs/nh.nix
    ../../programs/nix-index.nix
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

  # Services to start
  services = {
    # 禁用 X Server
    xserver = {
      enable = false;
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
    };

    # 监控硬盘健康的工具
    smartd = {
      enable = false;
      autodetect = true;
    };

    gvfs.enable = true; # 提供虚拟文件系统，允许你通过统一的接口访问网络和远程文件系统
    tumbler.enable = true; # 生成文件缩略图的后台服务
    # https://github.com/nix-community/NixOS-WSL/issues/846
    envfs.enable = true; # 许通过 /env 路径访问环境变量
    dbus.enable = true; # 进程间通信（IPC）的系统总线

    # 清理 SSD 上无用数据块的工具
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    libinput.enable = true; # 输入设备驱动
    fwupd.enable = true; # 管理和更新硬件固件
    upower.enable = true; # 管理电池、能源和电源管理的守护进程

    # 用于文件同步的工具
    # syncthing = {
    #   enable = false;
    #   user = "${username}";
    #   dataDir = "/home/${username}";
    #   configDir = "/home/${username}/.config/syncthing";
    # };
  };

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?
}
