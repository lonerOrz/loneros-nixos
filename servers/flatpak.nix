{
  lib,
  pkgs,
  inputs,
  config,
  username,
  ...
}:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  services.flatpak = {
    enable = true;
    remotes = lib.mkOptionDefault [
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];
    update = {
      auto = {
        enable = true;
        onCalendar = "weekly"; # 每周自动更新
      };
    };
    uninstallUnmanaged = false;
    uninstallUnused = true;
    packages = [
      {
        appId = "com.tencent.wemeet";
        origin = "flathub";
      }
      # { appId = "com.brave.Browser"; origin = "flathub"; }
      # "com.obsproject.Studio"
      # "im.riot.Riot"
    ];
    overrides = {
      # "com.brave.Browser".Context.filesystems = [ "home" ]; # 允许 Brave 访问主目录
    };
  };

  # systemd.services.flatpak-repo = {
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ pkgs.flatpak ];
  #   script = ''
  #     flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  #   '';
  # };

  # for user
  #users.users."${username}" = {
  #  packages = with pkgs; [
  #    flatpak
  #    gnome.gnome-software
  #  ];
  #};
}
