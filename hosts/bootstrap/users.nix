{
  pkgs,
  config,
  username,
  ...
}:
{
  users = {
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      hashedPassword = "$y$j9T$G4/aaUi6RJ96LQF2eWcGj1$h4ak4cLJGzwYqcRoyOzhNU8KVdCBtEL64h.xuIZFbmC";
      # hashedPasswordFile = config.sops.secrets."bootstrap/loner/password".path; # nixos-anytwhere 不起作用
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
    users.root = {
      hashedPasswordFile = config.sops.secrets."bootstrap/loner/password".path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8G+7o2ha+96GH3l/7c6IYGtUtuQHZCyXlZX8ZYPUhr lonerOrz@qq.com"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    git
    neovim
    firefox
    curl
    wget
    yazi
  ];

}
