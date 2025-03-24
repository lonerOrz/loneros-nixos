{
  pkgs,
  lib,
  system,
  inputs,
  username,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
in
{
  imports = [ inputs.spicetify-nix.nixosModules.default ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "spotify" ];

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "CatppuccinMacchiato";

    enabledExtensions = with spicePkgs.extensions; [
      autoSkipVideo # 自动跳过视频
      playlistIcons # 播放列表图标
      #powerBar # 搜索栏
      #lastfm # last.fm
      historyShortcut # 历史
      beautifulLyrics # 歌词
      volumePercentage # 音量百分比
      hidePodcasts # 隐藏播客
      adblock # 广告拦截
      fullAppDisplay # 全屏显示封面
      #popupLyrics # 弹出歌词
      shuffle # 随机播放
    ];
    enabledCustomApps = with spicePkgs.apps; [
      lyricsPlus
      marketplace
    ];
    enabledSnippets = with spicePkgs.snippets; [
      rotatingCoverart # 旋转艺术封面
      pointer
    ];
  };

  # stylix.targets.spicetify.enable = true;

  # 使用自定义配置文件控制spicetify
  environment.systemPackages = with pkgs; [
    spotify
    # spicetify-cli # 设置不了config
  ];
}
