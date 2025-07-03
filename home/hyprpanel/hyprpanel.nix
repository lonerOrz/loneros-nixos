{
  inputs,
  config,
  pkgs,
  ...
}:
let
  accent = "#${config.lib.stylix.colors.base0D}"; # 强调颜色
  accent-alt = "#${config.lib.stylix.colors.base03}"; # 替代强调颜色
  background = "#${config.lib.stylix.colors.base00}"; # 背景颜色
  background-alt = "#${config.lib.stylix.colors.base01}"; # 替代背景颜色
  foreground = "#${config.lib.stylix.colors.base05}"; # 前景颜色
  # base08: "#f38ba8" # red
  # base09: "#fab387" # peach
  # base0A: "#f9e2af" # yellow
  # base0B: "#a6e3a1" # green
  # base0C: "#94e2d5" # teal
  # base0D: "#89b4fa" # blue
  # base0E: "#cba6f7" # mauve
  # base0F: "#f2cdcd" # flamingo

  font = "FiraCode Nerd Font Mono"; # 字体
  fontSize = "10"; # 字号

  rounding = 10; # 圆角
  border-size = 3; # 边框大小

  gaps-out = 1; # 外边距
  gaps-in = 1; # 内边距

  floating = true; # 浮动窗口
  transparent = true; # 透明窗口
  transparentButtons = false; # 透明按钮
  position = "top"; # 位置（top 或 bottom）

  location = "en"; # 地理位置（用于天气等）
in
{
  home.packages = with pkgs; [
    adwaita-icon-theme # GNOME 图标主题
  ];

  programs.hyprpanel = {
    enable = true; # 启用 hyprpanel
    hyprland.enable = true; # 启用 Hyprland
    overwrite.enable = true; # 启用覆盖功能
    overlay.enable = true; # 启用覆盖层
    layout = {
      "bar.layouts" = {
        "*" = {
          "left" = [
            "dashboard"
            "workspaces"
            "windowtitle"
          ]; # 左侧内容（仪表盘，工作区，窗口标题）
          "middle" = [
            "media"
            "cava"
          ]; # 中间内容（媒体，Cava）
          "right" = [
            "systray" # 系统托盘
            "volume" # 音量
            "bluetooth" # 蓝牙
            "battery" # 电池
            "network" # 网络
            "clock" # 时钟
            "notifications" # 通知
          ];
        };
      };
    };

    override = {
      # 字体设置
      "theme.font.name" = "${font}";
      "theme.font.size" = "${fontSize}px";

      # 外部间距
      "theme.bar.outer_spacing" = "${if floating && transparent then "0" else "8"}px";
      "theme.bar.buttons.y_margins" = "${if floating && transparent then "0" else "8"}px";
      "theme.bar.buttons.spacing" = "0.3em";
      "theme.bar.buttons.radius" = "${
        if transparent then toString rounding else toString (rounding - 8)
      }px";
      "theme.bar.floating" = "${if floating then "true" else "false"}";
      "theme.bar.buttons.padding_x" = "0.8rem";
      "theme.bar.buttons.padding_y" = "0.4rem";
      "theme.bar.buttons.workspaces.hover" = "${accent-alt}";
      "theme.bar.buttons.workspaces.active" = "${accent}";
      "theme.bar.buttons.workspaces.available" = "${accent-alt}";
      "theme.bar.buttons.workspaces.occupied" = "${accent-alt}";

      # 顶部和底部边距
      "theme.bar.margin_top" = "${if position == "top" then toString (gaps-in * 2) else "0"}px";
      "theme.bar.margin_bottom" = "${if position == "top" then "0" else toString (gaps-in * 2)}px";

      # 侧边和圆角
      "theme.bar.margin_sides" = "${toString gaps-out}px";
      "theme.bar.border_radius" = "${toString rounding}px";
      "bar.launcher.icon" = ""; # 启动器图标

      # 是否透明
      "theme.bar.transparent" = "${if transparent then "true" else "false"}";
      "bar.workspaces.show_numbered" = false; # 不显示工作区编号
      "bar.workspaces.workspaces" = 10; # 显示 5 个工作区
      "bar.workspaces.hideUnoccupied" = false; # 不隐藏空闲工作区
      "bar.windowtitle.label" = true; # 显示窗口标题
      "bar.volume.label" = false; # 不显示音量标签
      "bar.network.truncation_size" = 12; # 网络标签截断长度
      "bar.bluetooth.label" = false; # 不显示蓝牙标签
      "bar.clock.format" = "%a %b %d  %I:%M %p"; # 时钟格式
      "bar.notifications.show_total" = true; # 显示总通知数
      "theme.notification.border_radius" = "${toString rounding}px";

      # OSD 设置（屏幕显示）
      "theme.osd.enable" = true; # 启用 OSD
      "theme.osd.orientation" = "vertical"; # 垂直方向
      "theme.osd.location" = "left"; # 位于左侧
      "theme.osd.radius" = "${toString rounding}px";
      "theme.osd.margins" = "0px 0px 0px 10px";
      "theme.osd.muted_zero" = true; # 静音时显示零

      # 天气位置和单位设置
      "menus.clock.weather.location" = "${location}";
      "menus.clock.weather.unit" = "metric"; # 温度单位：公制
      "menus.dashboard.powermenu.confirmation" = false; # 关闭电源菜单确认
      "menus.dashboard.powermenu.avatar.image" = "~/.config/hyprpanel/avatar.png"; # 电源菜单头像

      # 自定义快捷方式设置
      "menus.dashboard.shortcuts.left.shortcut1.icon" = "";
      "menus.dashboard.shortcuts.left.shortcut1.command" = "zen";
      "menus.dashboard.shortcuts.left.shortcut1.tooltip" = "Zen";
      "menus.dashboard.shortcuts.left.shortcut2.icon" = "󰅶";
      "menus.dashboard.shortcuts.left.shortcut2.command" = "caffeine";
      "menus.dashboard.shortcuts.left.shortcut2.tooltip" = "Caffeine";
      "menus.dashboard.shortcuts.left.shortcut3.icon" = "󰖔";
      "menus.dashboard.shortcuts.left.shortcut3.command" = "night-shift";
      "menus.dashboard.shortcuts.left.shortcut3.tooltip" = "Night-shift";
      "menus.dashboard.shortcuts.left.shortcut4.icon" = "";
      "menus.dashboard.shortcuts.left.shortcut4.command" = "menu";
      "menus.dashboard.shortcuts.left.shortcut4.tooltip" = "Search Apps";
      "menus.dashboard.shortcuts.right.shortcut1.icon" = "";
      "menus.dashboard.shortcuts.right.shortcut1.command" = "hyprpicker -a";
      "menus.dashboard.shortcuts.right.shortcut1.tooltip" = "Color Picker";
      "menus.dashboard.shortcuts.right.shortcut3.icon" = "󰄀";
      "menus.dashboard.shortcuts.right.shortcut3.command" = "screenshotmenu";
      "menus.dashboard.shortcuts.right.shortcut3.tooltip" = "Screenshot";

      # 菜单样式设置
      "theme.bar.menus.monochrome" = true; # 单色模式
      "wallpaper.enable" = false; # 不启用壁纸
      "theme.bar.menus.background" = "${background}";
      "theme.bar.menus.cards" = "${background-alt}";
      "theme.bar.menus.card_radius" = "${toString rounding}px";
      "theme.bar.menus.label" = "${foreground}";
      "theme.bar.menus.text" = "${foreground}";
      "theme.bar.menus.border.size" = "${toString border-size}px";
      "theme.bar.menus.border.color" = "${accent}";
      "theme.bar.menus.border.radius" = "${toString rounding}px";
      "theme.bar.menus.popover.text" = "${foreground}";
      "theme.bar.menus.popover.background" = "${background-alt}";
      "theme.bar.menus.listitems.active" = "${accent}";
      "theme.bar.menus.icons.active" = "${accent}";
      "theme.bar.menus.switch.enabled" = "${accent}";
      "theme.bar.menus.check_radio_button.active" = "${accent}";
      "theme.bar.menus.buttons.default" = "${accent}";
      "theme.bar.menus.buttons.active" = "${accent}";
      "theme.bar.menus.iconbuttons.active" = "${accent}";
      "theme.bar.menus.progressbar.foreground" = "${accent}";
      "theme.bar.menus.slider.primary" = "${accent}";
      "theme.bar.menus.tooltip.background" = "${background-alt}";
      "theme.bar.menus.tooltip.text" = "${foreground}";
      "theme.bar.menus.dropdownmenu.background" = "${background-alt}";
      "theme.bar.menus.dropdownmenu.text" = "${foreground}";

      # 导航栏按钮背景色等设置
      "theme.bar.background" = "${background + (if transparentButtons && transparent then "00" else "")}";
      "theme.bar.buttons.style" = "default";
      "theme.bar.buttons.monochrome" = true;
      "theme.bar.buttons.text" = "${foreground}";
      "theme.bar.buttons.background" = "${
        (if transparent then background else background-alt) + (if transparentButtons then "00" else "")
      }";
      "theme.bar.buttons.icon" = "${accent}";
      "theme.bar.buttons.notifications.background" = "${background-alt}";
      "theme.bar.buttons.hover" = "${background}";
      "theme.bar.buttons.notifications.hover" = "${background}";
      "theme.bar.buttons.notifications.total" = "${accent}";
      "theme.bar.buttons.notifications.icon" = "${accent}";

      # 通知相关设置
      "theme.notification.background" = "${background-alt}";
      "theme.notification.actions.background" = "${accent}";
      "theme.notification.actions.text" = "${foreground}";
      "theme.notification.label" = "${accent}";
      "theme.notification.border" = "${background-alt}";
      "theme.notification.text" = "${foreground}";
      "theme.notification.labelicon" = "${accent}";
      "theme.notification.position" = "TOP LEFT";

      # OSD 设置
      "theme.osd.bar_color" = "${accent}";
      "theme.osd.bar_overflow_color" = "${accent-alt}";
      "theme.osd.icon" = "${background}";
      "theme.osd.icon_container" = "${accent}";
      "theme.osd.label" = "${accent}";
      "theme.osd.bar_container" = "${background-alt}";

      # 多媒体菜单背景色
      "theme.bar.menus.menu.media.background.color" = "${background-alt}";
      "theme.bar.menus.menu.media.card.color" = "${background-alt}";
      "theme.bar.menus.menu.media.card.tint" = 90;

      # 更新轮询间隔
      "bar.customModules.updates.pollingInterval" = 1440000;
      "bar.media.show_active_only" = true;

      # 导航栏位置
      "theme.bar.location" = "${position}";
      "bar.workspaces.numbered_active_indicator" = "color";
      "bar.workspaces.monitorSpecific" = false;
      "bar.workspaces.applicationIconEmptyWorkspace" = "";
      "bar.workspaces.showApplicationIcons" = true;
      "bar.workspaces.showWsIcons" = true;
      "theme.bar.dropdownGap" = "4.5em";

      # 自定义模块：Cava
      "bar.customModules.cava.showIcon" = false;
      "bar.customModules.cava.stereo" = true;
      "bar.customModules.cava.showActiveOnly" = true;
    };
  };
}
