{
  inputs,
  config,
  pkgs,
  lib,
  modulesPath,
  host,
  username,
  ...
}@args:
{
  imports = [
    # (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.tuckr-nix.tuckrModules.default
    ./disko.nix
    (if builtins.pathExists ./hardware.nix then ./hardware.nix else { })
    ./persistent.nix
  ];

  boot.kernelParams = [
    # 关闭内核的操作审计功能
    "audit=0"
    # 不要根据 PCIe 地址生成网卡名（例如 enp1s0，对 VPS 没用），而是直接根据顺序生成（例如 eth0）
    # "net.ifnames=0"
  ];

  # 我用的 Initrd 配置，开启 ZSTD 压缩和基于 systemd 的第一阶段启动
  boot.initrd = {
    compressor = "zstd";
    compressorArgs = [
      "-19"
      "-T0"
    ];
    systemd.enable = true;
  };

  # systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    fastfetch
    git
    neovim
    firefox
    curl
    wget
    yazi
  ];

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    nerd-fonts.jetbrains-mono # unstable
    nerd-fonts.fira-code # unstable
    lxgw-wenkai # wenkai mono
    maple-mono.NF-CN # 开源等宽中文
  ];

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # 基础网络 + SSH
  networking.hostName = "${host}";
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false; # disable firewall

  # 创建用户
  users = {
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      hashedPassword = "$y$j9T$G4/aaUi6RJ96LQF2eWcGj1$h4ak4cLJGzwYqcRoyOzhNU8KVdCBtEL64h.xuIZFbmC";
      # hashedPasswordFile = config.sops.secrets."remote-vm/loner/password".path; # nixos-anytwhere 不起作用
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8G+7o2ha+96GH3l/7c6IYGtUtuQHZCyXlZX8ZYPUhr lonerOrz@qq.com"
      ];
      extraGroups = [
        "networkmanager"
        "wheel"
        "scanner"
        "lp"
        "video"
        "input"
        "audio"
      ];
    };
  };

  # 开启模块
  tuckr.enable = true; # 必须保留
  tuckr.users = {
    ${username} = {
      enable = true;
      dotPath = "~/.config";
      backupSuffix = "bak";
      group = {
        nvim.enable = true;
        fzf.enable = true;
        fastfetch.enable = false;
      };
    };
  };

  # security
  # 允许 wheel 组成员用 sudo
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

  # for devlopment
  users.users.root.hashedPassword = "$y$j9T$G4/aaUi6RJ96LQF2eWcGj1$h4ak4cLJGzwYqcRoyOzhNU8KVdCBtEL64h.xuIZFbmC";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8G+7o2ha+96GH3l/7c6IYGtUtuQHZCyXlZX8ZYPUhr lonerOrz@qq.com"
  ];

  # enable features
  nix.settings.experimental-features = [
    "nix-command" # 启用 nix build, nix run, nix flake 等新命令
    "flakes"
  ];
  # 禁用远程机器的签名验证,(懒得给本地构建路径签名)
  # nix.settings.require-sigs = false;
  # 强制使用本地 cahe
  # nix.settings.substituters = lib.mkForce [ "http://192.168.2.6:5000" ];

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?
}
