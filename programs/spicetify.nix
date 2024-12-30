# Spicetify is a spotify client customizer
{ pkgs,
  lib,
  system,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  # accent = "A594FD";
in {
  imports = [ inputs.spicetify-nix.nixosModules.default ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "spotify" ];

  programs.spicetify = {
    enable = true;
    theme = lib.mkForce spicePkgs.themes.text;

    colorScheme = "Nord";

    enabledExtensions = with spicePkgs.extensions; [
      playlistIcons # 播放列表图标
      powerBar # 搜索栏
      lastfm # last.fm
      historyShortcut # 历史
      beautifulLyrics # 歌词
      volumePercentage # 音量百分比
      hidePodcasts # 隐藏播客
      adblock # 广告拦截
      fullAppDisplay # 全屏显示封面
      popupLyrics # 弹出歌词
      shuffle # 随机播放
    ];
  };
}
