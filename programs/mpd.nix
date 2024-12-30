{
  config,
  pkgs,
  username,
  ...
}:
{
  # 启用 MPD 服务
  services.mpd = {
    enable = true;
    user = "${username}"; # MPD 运行的用户
    #group = "${username}";  # MPD 运行的用户组
    musicDirectory = "/home/${username}/Music/localmusic";

    # 指定 mpd.conf 配置文件路径
    extraConfig = ''
      playlist_directory      "/home/${username}/.config/mpd/playlists"
      db_file                 "/home/${username}/.config/mpd/database"
      log_file                "/home/${username}/.config/mpd/log"
      pid_file                "/home/${username}/.config/mpd/mpd.pid"
      state_file              "/home/${username}/.config/mpd/state"
      bind_to_address         "localhost"
      port                    "6600"
      log_level               "default"
      restore_paused          "yes"
      auto_update             "yes"
      auto_update_depth       "4"

      audio_output {
        type  "pipewire"
        name  "Pipewire Sound Server"
      }

      audio_output {
        type	"fifo"
        name	"my_fifo"
        path	"/home/${username}/.config/mpd/mpd.fifo"
        format	"44100:16:2"
      }
    '';
  };
}
