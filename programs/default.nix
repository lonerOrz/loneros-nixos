{
  imports = [
    #system
    ./mime.nix

    # program
    ./nh.nix
    ./git.nix
    ./nix-index.nix
    ./fcitx5.nix
    ./spicetify.nix
    # ./virtualbox.nix
    ./virt-manager.nix # kvm + qemu + virt-manager
    # ./flatpak.nix
    ./steam.nix
    ./wshowkeys.nix
    ./discord.nix
    ./firefox.nix
    # ./nvf.nix
    # ./clash.nix
    ./direnv.nix
    ./obs.nix
    ./ax-shell.nix
    ./nvim.nix
    ./quickshell.nix
    ./ags.nix
    ./niri.nix
    ./wine.nix
    ./hmcl.nix
    ./gimp.nix
    ./qq.nix

    # server
    ./mpd.nix
    ./nfs.nix
    ./nbfc.nix
    ./ollama.nix
    ./mihomo.nix
    ./rclone.nix
    ./sunshine.nix
    ./wayvnc.nix
    ./docker.nix
    ./jellyfin.nix
    # ./aria2.nix # 使用 docker-compose
    ./tailscale.nix
    ./atuin.nix
  ];
}
