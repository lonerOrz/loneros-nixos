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
    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };
    musicDirectory = "/home/${username}/Music/localmusic";
    playlistDirectory = "/home/${username}/.config/mpd/playlists";
    dbFile = "/home/${username}/.config/mpd/database";

    # 指定 mpd.conf 配置文件路径
    extraConfig = ''
      log_file                "/home/${username}/.config/mpd/log"
      pid_file                "/home/${username}/.config/mpd/mpd.pid"
      state_file              "/home/${username}/.config/mpd/state"
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
  environment.systemPackages = with pkgs; [
    mpd
    ncmpcpp
  ];
}
