{ config, ... }:
let
  # 定义 Stylix 颜色变量，确保正确嵌入字符串
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
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ base0D ];
          inactiveBorderColor = [ base0B ];
          optionsTextColor = [ base0D ];
          selectedLineBgColor = [ base02 ];
          cherryPickedCommitBgColor = [ base03 ];
          cherryPickedCommitFgColor = [ base0D ];
          unstagedChangesColor = [ base08 ];
          defaultFgColor = [ base05 ];
          searchingActiveBorderColor = [ base0A ];
        };
        authorColors = {
          "*" = base07;
        };
      };
    };
  };
}
