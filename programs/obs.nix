{
  config,
  pkgs,
  stable,
  ...
}:
{
  programs.obs-studio = {
    enable = true;
    plugins = with stable.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
}
