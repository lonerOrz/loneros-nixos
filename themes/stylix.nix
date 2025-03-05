# 暂时我就只控制 zenbrowser qutebrowser spicetify 的主题，像waybar,rofi之类的暂时没找到更换样式的方法，使用主题设置也就只能等 TODO

{ pkgs, inputs, ... }:
let
  colorScheme = rec {
    custom = false;
    name = "rose-pine-moon"; # catppuccin-mocha, tokyo-night-moon, solarized-dark, rose-pine-moon, nord, gruvbox-dark-hard
    path =
      if custom
      then ./colorschemes/${name}.yaml
      else "${pkgs.base16-schemes}/share/themes/${name}.yaml";
    polarity = "dark";
  };
in 
{
  stylix = {
    enable = true;
    autoEnable = false; # 关闭默认的自动应用主题
    base16Scheme = colorScheme.path;
  };
}
