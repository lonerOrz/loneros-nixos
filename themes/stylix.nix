# 暂时我就只控制 zenbrowser qutebrowser spicetify cava hyprpanel bottom btop lazygit 的主题，像waybar,rofi之类的暂时没找到更换样式的方法，使用主题设置也就只能等 TODO

{ pkgs, inputs, ... }:
let
  colorScheme = rec {
    custom = false;
    name = "catppuccin-mocha";
    # catppuccin-mocha frappe latte macchiato
    # tokyo-night-moon
    # solarized-dark
    # rose-pine-moon
    # nord
    # darcula
    # gruvbox-dark-medium
    # monokai
    # moonlight
    # kanagawa
    path =
      if custom then ./colorschemes/${name}.yaml else "${pkgs.base16-schemes}/share/themes/${name}.yaml";
    polarity = "dark";
  };
in
{
  stylix = {
    enable = true;
    autoEnable = false; # 关闭默认的自动应用主题
    base16Scheme = colorScheme.path;
    polarity = "${colorScheme.polarity}";
    # cursor = {
    #   package = pkgs.nordzy-cursor-theme;
    #   name = "nordzy-catppuccin-mocha-grren";
    #   size = 24;
    # };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono Nerd Font";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 13;
        desktop = 13;
        popups = 13;
        terminal = 13;
      };
    };
  };
}
