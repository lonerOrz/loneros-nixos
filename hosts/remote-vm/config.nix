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
      hashedPassword = "$y$j9T$G4/aaUi6RJ96LQF2eWcGj1$h4ak4cLJGzwYqcRoyOzhNU8KVdCBtEL64h.xuIZFbmC";
      # hashedPasswordFile = config.sops.secrets."remote-vm/test/password".path; # nixos-anytwhere 不起作用
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

  # for devlopment
  users.users.root.hashedPassword = "$y$j9T$G4/aaUi6RJ96LQF2eWcGj1$h4ak4cLJGzwYqcRoyOzhNU8KVdCBtEL64h.xuIZFbmC";

  # enable features
  nix.settings.experimental-features = [
    "nix-command" # 启用 nix build, nix run, nix flake 等新命令
    "flakes"
  ];

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
