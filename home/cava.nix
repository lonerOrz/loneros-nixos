{
  config,
  pkgs,
  ...
}:
let
  # 提取 Stylix 的 16 色
  base00 = "#${config.lib.stylix.colors.base00}";
  base01 = "#${config.lib.stylix.colors.base01}";
  base02 = "#${config.lib.stylix.colors.base02}";
  base03 = "#${config.lib.stylix.colors.base03}";
  base04 = "#${config.lib.stylix.colors.base04}";
  base05 = "#${config.lib.stylix.colors.base05}";
  base06 = "#${config.lib.stylix.colors.base06}";
  base07 = "#${config.lib.stylix.colors.base07}";
  base08 = "#${config.lib.stylix.colors.base08}";
  base09 = "#${config.lib.stylix.colors.base09}";
  base0A = "#${config.lib.stylix.colors.base0A}";
  base0B = "#${config.lib.stylix.colors.base0B}";
  base0C = "#${config.lib.stylix.colors.base0C}";
  base0D = "#${config.lib.stylix.colors.base0D}";
  base0E = "#${config.lib.stylix.colors.base0E}";
  base0F = "#${config.lib.stylix.colors.base0F}";
in
{
  programs.cava = {
    enable = true;
    settings = {
      general = {
        framerate = 60; # 示例值，更保守
        autosens = 1; # 一致，启用自动灵敏度
        sensitivity = 100; # 示例值，初始灵敏度稍低
        bars = 0; # 一致，自动填充
        bar_width = 2; # 示例值，柱宽 2 字符
        bar_spacing = 1; # 示例值，间距 1 字符
        lower_cutoff_freq = 50; # 示例值，窄化低频范围
        higher_cutoff_freq = 10000; # 示例值，窄化高频范围
        sleep_timer = 0; # 示例值，禁用休眠
      };

      # 输入设置 - 与示例一致
      input = {
        method = "pulse";
        source = "auto";
      };

      # 输出设置 - 保留 noncurses，示例倾向 ncurses
      output = {
        method = "noncurses"; # 性能优于 ncurses，接近示例
        channels = "stereo";
      };

      # 颜色设置 - 保留 Stylix 颜色
      color = {
        # background = "'${base00}'"; # 取消后背景透明
        gradient = 1;
        gradient_count = 8;
        gradient_color_1 = "'${base0B}'";
        gradient_color_2 = "'${base0C}'";
        gradient_color_3 = "'${base0D}'";
        gradient_color_4 = "'${base0E}'";
        gradient_color_5 = "'${base09}'";
        gradient_color_6 = "'${base0A}'";
        gradient_color_7 = "'${base08}'";
        gradient_color_8 = "'${base0F}'";
      };

      # 平滑设置 - 与示例对齐
      smoothing = {
        integral = 77; # 示例值，稍低平滑度
        monstercat = 0; # 示例值，禁用 Monstercat
        gravity = 100; # 示例值，下降较慢
        ignore = 0; # 一致
      };

      # 均衡器设置 - 保留你的轻微调整
      eq = {
        "1" = 1.2; # 低音增强
        "2" = 1.0;
        "3" = 1.0; # 中音默认
        "4" = 1.0;
        "5" = 1.1; # 高音提升
      };
    };
  };

  home.packages = with pkgs; [
    cava
  ];
}
