{
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  # TODO: 添加一个桌面

  environment.systemPackages = with pkgs; [
    fastfetch
    git
    neovim
    firefox
    curl
    wget
    yazi
    calamares-nixos # 安装程序的图形界面
  ];

  services.getty.autologinUser = "root"; # 自动以 root 用户登录
  users.users.root.initialPassword = "123456";

  # FONTS
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    nerd-fonts.jetbrains-mono # unstable
    nerd-fonts.fira-code # unstable
    lxgw-wenkai # wenkai mono
    maple-mono.NF-CN # 开源等宽中文
  ];

  nix.settings.experimental-features = [
    "nix-command" # 启用 nix build, nix run, nix flake 等新命令
    "flakes"
  ];

  # 网络
  networking.networkmanager.enable = true;
  networking.hostName = "nixos-live";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes"; # 允许 root 密码登录
      PasswordAuthentication = true; # 允许密码登录（默认是 true）
    };
  };

  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      pulse.enable = true; # PulseAudio 兼容层,产生.pulse-cookie文件
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # 时区和语言
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "25.05"; # 请根据实际情况设置
}
