{
  inputs,
  pkgs,
  host,
  ...
}:
let
  ghostty = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = (with pkgs; [ ghostty ]);

  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = "FiraCode Nerd Font Mono Bold"
    font-size = 11
    font-thicken = true
    font-feature = ss01
    font-feature = ss04

    bold-is-bright = false
    adjust-box-thickness = 1

    # Theme
    theme = "catppuccin-mocha"
    background-opacity = 0.7

    cursor-style = bar
    cursor-style-blink = false
    adjust-cursor-thickness = 1

    resize-overlay = never
    copy-on-select = false
    confirm-close-surface = false
    mouse-hide-while-typing = true

    window-theme = ghostty
    # 设置窗口左右和上下的内边距
    window-padding-x = 4
    window-padding-y = 6
    window-padding-balance = true
    window-padding-color = background
    window-inherit-working-directory = true
    window-inherit-font-size = true
    window-decoration = false

    gtk-titlebar = false
    gtk-single-instance = false
    gtk-tabs-location = bottom
    gtk-wide-tabs = false

    auto-update = off
    term = ghostty
    clipboard-paste-protection = false

    # 解除快捷键绑定
    keybind = shift+end=unbind
    keybind = shift+home=unbind
    keybind = ctrl+shift+left=unbind
    keybind = ctrl+shift+right=unbind
    # 设置Shift+Enter为插入换行符
    keybind = shift+enter=text:\n
  '';
}
