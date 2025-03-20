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
  home.file.".zen/${path}/chrome/userContent.css" = {
    text = ''
      @media (prefers-color-scheme: dark) {
        @-moz-document url-prefix("about:") {
          :root {
            --in-content-page-color: #${base04} !important;
            --color-accent-primary: #${base0B} !important;
            --color-accent-primary-hover: rgb(185, 233, 181) !important; /* 保留RGB */
            --color-accent-primary-active: rgb(161, 227, 172) !important; /* 保留RGB */
            background-color: #${base01} !important;
            --in-content-page-background: #${base01} !important;
          }
        }

        @-moz-document url("about:newtab"), url("about:home") {
          :root {
            --newtab-background-color: #${base01} !important;
            --newtab-background-color-secondary: #${base02} !important;
            --newtab-element-hover-color: #${base02} !important;
            --newtab-text-primary-color: #${base04} !important;
            --newtab-wordmark-color: #${base04} !important;
            --newtab-primary-action-background: #${base0B} !important;
          }
          .icon { color: #${base0B} !important; }
          .card-outer:is(:hover, :focus, .active):not(.placeholder) .card-title {
            color: #${base0B} !important;
          }
          .top-site-outer .search-topsite {
            background-color: #${base0D} !important;
          }
        }

        @-moz-document url-prefix("about:preferences") {
          :root {
            --zen-colors-tertiary: #${base00} !important;
            --in-content-text-color: #${base04} !important;
            --link-color: #${base0B} !important;
            --link-color-hover: rgb(185, 233, 181) !important; /* 保留RGB */
            --zen-colors-primary: #${base02} !important;
            --in-content-box-background: #${base02} !important;
            --zen-primary-color: #${base0B} !important;
          }
          groupbox, moz-card { background: #${base01} !important; }
          button, groupbox menulist { background: #${base02} !important; color: #${base04} !important; }
          .main-content { background-color: #${base00} !important; }
          .identity-color-blue { --identity-tab-color: #${base0D} !important; --identity-icon-color: #${base0D} !important; }
          .identity-color-turquoise { --identity-tab-color: #${base0C} !important; --identity-icon-color: #${base0C} !important; }
          .identity-color-green { --identity-tab-color: #${base0B} !important; --identity-icon-color: #${base0B} !important; }
          .identity-color-yellow { --identity-tab-color: #${base0A} !important; --identity-icon-color: #${base0A} !important; }
          .identity-color-orange { --identity-tab-color: #${base09} !important; --identity-icon-color: #${base09} !important; }
          .identity-color-red { --identity-tab-color: #${base08} !important; --identity-icon-color: #${base08} !important; }
          .identity-color-pink { --identity-tab-color: #${base0F} !important; --identity-icon-color: #${base0F} !important; }
          .identity-color-purple { --identity-tab-color: #${base0E} !important; --identity-icon-color: #${base0E} !important; }
        }

        @-moz-document url-prefix("about:addons") {
          :root {
            --zen-dark-color-mix-base: #${base00} !important;
            --background-color-box: #${base01} !important;
          }
        }

        @-moz-document url-prefix("about:protections") {
          :root {
            --zen-primary-color: #${base01} !important;
            --social-color: #${base0E} !important;
            --coockie-color: #${base0C} !important;
            --fingerprinter-color: #${base0A} !important;
            --cryptominer-color: #${base06} !important;
            --tracker-color: #${base0B} !important;
            --in-content-primary-button-background-hover: #${base03} !important;
            --in-content-primary-button-text-color-hover: #${base04} !important;
            --in-content-primary-button-background: #${base03} !important;
            --in-content-primary-button-text-color: #${base04} !important;
          }
          .card { background-color: #${base02} !important; }
        }
      }
    '';
  };
}
