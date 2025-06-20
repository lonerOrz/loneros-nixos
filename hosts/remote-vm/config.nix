{
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
    ./disko.nix
  ];

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
      hashedPasswordFile = config.sops.secrets."remote-vm/test/password".path;
      # initialPassword = "123456"; # 初始化用户密码
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

  # enable flake
  nix.settings.experimental-features = [
    "nix-command" # 启用 nix build, nix run, nix flake 等新命令
    "flakes"
    # "ca-derivations" # 启用内容寻址 derivation（Content Addressed Derivations）
  ];

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
