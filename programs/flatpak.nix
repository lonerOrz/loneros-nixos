{
  config,
  pkgs,
  username,
  ...
}:
{
  #  for all users
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # for user
  #users.users."${username}" = {
  #  packages = with pkgs; [
  #    flatpak
  #    gnome.gnome-software
  #  ];
  #};
}
