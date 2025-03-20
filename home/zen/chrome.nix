{
  config,
  path,
  ...
}:
let
  base00 = config.lib.stylix.colors.base00;
  base01 = config.lib.stylix.colors.base01;
  base02 = config.lib.stylix.colors.base02;
  base03 = config.lib.stylix.colors.base03;
  base04 = config.lib.stylix.colors.base04;
  base05 = config.lib.stylix.colors.base05;
  base06 = config.lib.stylix.colors.base06;
  base07 = config.lib.stylix.colors.base07;
  base08 = config.lib.stylix.colors.base08;
  base09 = config.lib.stylix.colors.base09;
  base0A = config.lib.stylix.colors.base0A;
  base0B = config.lib.stylix.colors.base0B;
  base0C = config.lib.stylix.colors.base0C;
  base0D = config.lib.stylix.colors.base0D;
  base0E = config.lib.stylix.colors.base0E;
  base0F = config.lib.stylix.colors.base0F;
in
{
  home.file.".zen/${path}/chrome/userChrome.css" = {
    text = ''
      @media (prefers-color-scheme: dark) {
        :root {
          --zen-colors-primary: #${base02} !important;
          --zen-primary-color: #${base0B} !important;
          --zen-colors-secondary: #${base02} !important;
          --zen-colors-tertiary: #${base00} !important;
          --zen-colors-border: #${base0B} !important;
          --toolbarbutton-icon-fill: #${base0B} !important;
          --lwt-text-color: #${base04} !important;
          --toolbar-field-color: #${base04} !important;
          --tab-selected-textcolor: #${base0B} !important;
          --toolbar-field-focus-color: #${base04} !important;
          --toolbar-color: #${base04} !important;
          --newtab-text-primary-color: #${base04} !important;
          --arrowpanel-color: #${base04} !important;
          --arrowpanel-background: #${base01} !important;
          --sidebar-text-color: #${base04} !important;
          --lwt-sidebar-text-color: #${base04} !important;
          --lwt-sidebar-background-color: #${base00} !important;
          --toolbar-bgcolor: #${base02} !important;
          --newtab-background-color: #${base01} !important;
          --zen-themed-toolbar-bg: #${base00} !important;
          --zen-main-browser-background: #${base00} !important;
        }

        #permissions-granted-icon {
          color: #${base00} !important;
        }

        .sidebar-placesTree,
        #zen-workspaces-button,
        #urlbar-background,
        .content-shortcuts {
          background-color: #${base01} !important;
        }

        #TabsToolbar {
          background-color: #${base00} !important;
        }

        .content-shortcuts {
          border-color: #${base0B} !important;
        }

        .urlbarView-url {
          color: #${base0B} !important;
        }

        #zenEditBookmarkPanelFaviconContainer {
          background: #${base00} !important;
        }

        /* 强调色重定义 */
        .identity-color-blue { --identity-tab-color: #${base0D} !important; --identity-icon-color: #${base0D} !important; }
        .identity-color-turquoise { --identity-tab-color: #${base0C} !important; --identity-icon-color: #${base0C} !important; }
        .identity-color-green { --identity-tab-color: #${base0B} !important; --identity-icon-color: #${base0B} !important; }
        .identity-color-yellow { --identity-tab-color: #${base0A} !important; --identity-icon-color: #${base0A} !important; }
        .identity-color-orange { --identity-tab-color: #${base09} !important; --identity-icon-color: #${base09} !important; }
        .identity-color-red { --identity-tab-color: #${base08} !important; --identity-icon-color: #${base08} !important; }
        .identity-color-pink { --identity-tab-color: #${base0F} !important; --identity-icon-color: #${base0F} !important; }
        .identity-color-purple { --identity-tab-color: #${base0E} !important; --identity-icon-color: #${base0E} !important; }
      }
    '';
  };
}
