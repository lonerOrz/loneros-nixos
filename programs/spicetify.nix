{
  pkgs,
  lib,
  config,
  system,
  inputs,
  username,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  # 定义 Stylix 颜色变量，确保正确嵌入字符串
  base00 = "${config.lib.stylix.colors.base00}";
  base01 = "${config.lib.stylix.colors.base01}";
  base02 = "${config.lib.stylix.colors.base02}";
  base03 = "${config.lib.stylix.colors.base03}";
  base04 = "${config.lib.stylix.colors.base04}";
  base05 = "${config.lib.stylix.colors.base05}";
  base06 = "${config.lib.stylix.colors.base06}";
  base07 = "${config.lib.stylix.colors.base07}";
  base08 = "${config.lib.stylix.colors.base08}";
  base09 = "${config.lib.stylix.colors.base09}";
  base0A = "${config.lib.stylix.colors.base0A}";
  base0B = "${config.lib.stylix.colors.base0B}";
  base0C = "${config.lib.stylix.colors.base0C}";
  base0D = "${config.lib.stylix.colors.base0D}";
  base0E = "${config.lib.stylix.colors.base0E}";
  base0F = "${config.lib.stylix.colors.base0F}";
in
{
  imports = [ inputs.spicetify-nix.nixosModules.default ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "spotify" ];

  programs.spicetify = {
    enable = true;
    spotifyPackage = pkgs.spotify-wrapper;
    # windowManagerPatch = true; # wm补丁
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
    # customColorScheme = {
    #   text = base05;              # main text, playlist names in main field, name of playlist selected in sidebar, headings
    #   subtext = base02;           # text in main buttons in sidebar, playlist names in sidebar, artist names, and mini infos
    #   nav-active-text = base00;   # text in main buttons in sidebar when active
    #   main = base00;              # main bg
    #   main-secondary = base03;    # bg color of selected song rows, bg color of artist/track cards
    #   sidebar = base01;           # sidebar bg
    #   player = base0D;            # player bg
    #   card = base07;              # popup-card bg
    #   shadow = base0F;            # all shadows
    #   button = base03;            # playlist buttons bg in sidebar, drop-down menus, now playing song, like button
    #   button-secondary = base09;  # download and options button
    #   button-active = base0A;     # hover on song selected
    #   button-disabled = base02;   # seekbar bg, volume bar bg, scrollbar
    #   nav-active = base05;        # sidebar buttons bg
    #   play-button = base0B;       # color of main play button in main field
    #   tab-active = base0C;        # button bg in main field (playlists, podcasts, artists, albums)
    #   notification = base0E;      # notification ('Added to liked songs' etc.)
    #   playback-bar = base0D;      # seekbar fg, volume bar fg, main play/pause button
    #   misc = base04;              # miscellaneous
    # };

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
    # spotify
    # spicetify-cli # 设置不了config
  ];
}
