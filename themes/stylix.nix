{ pkgs, inputs, ... }:
let
  colorScheme = rec {
    custom = false;
    name = "nord"; # catppuccin-mocha, tokyo-night-moon, solarized-dark, rose-pine-moon, nord, gruvbox-dark-hard
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
