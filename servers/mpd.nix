{
  config,
  pkgs,
  username,
  ...
}:
{
  users.groups.mpd.members = [ "${username}" ];
  # 启用 MPD 服务
  services.mpd = {
    enable = true;
    startWhenNeeded = true;
    user = "${username}"; # MPD 运行的用户
    # group = "${username}"; # MPD 运行的用户组

    settings = {
      log_file = "/home/${username}/.config/mpd/log";
      pid_file = "/home/${username}/.config/mpd/mpd.pid";
      state_file = "/home/${username}/.config/mpd/state";
      log_level = "default";
      restore_paused = true;
      auto_update = true;
      auto_update_depth = 4;

      port = 6600;
      bind_to_address = "127.0.0.1";

      music_directory = "/home/${username}/Music/localmusic";
      playlist_directory = "/home/${username}/.config/mpd/playlists";
      db_file = "/home/${username}/.config/mpd/database";

      audio_output = [
        {
          type = "pipewire";
          name = "Pipewire Sound Server";
        }
        {
          type = "fifo";
          name = "my_fifo";
          path = "/home/${username}/.config/mpd/mpd.fifo";
          format = "44100:16:2";
        }
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    mpd
    ncmpcpp
  ];
}
