{
  config,
  path,
  highlightColor,
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
        /* 基本页面设置 */
        @-moz-document url-prefix("about:") {
          :root {
            --in-content-page-color: #${base05} !important;
            --color-accent-primary: #${highlightColor} !important;
            --color-accent-primary-hover: rgb(185, 233, 181) !important;
            --color-accent-primary-active: rgb(161, 227, 172) !important;
            --content-background-color: #${base01} !important;
            --content-text-color: #${base05} !important;
            --in-content-page-background: #${base01} !important;
          }
        }

        /* 新标签页和首页设置 */
        @-moz-document url("about:newtab"), url("about:home") {
          :root {
            --newtab-background-color: #${base01} !important;
            --newtab-background-color-secondary: #${base02} !important;
            --newtab-element-hover-color: #${base02} !important;
            --newtab-text-primary-color: #${base05} !important;
            --newtab-wordmark-color: #${base05} !important;
            --newtab-primary-action-background: #${highlightColor} !important;
          }
          .icon { color: #${highlightColor} !important; }
          .card-outer:is(:hover, :focus, .active):not(.placeholder) .card-title {
            color: #${highlightColor} !important;
          }
          .top-site-outer .search-topsite {
            background-color: #${base0D} !important;
          }
        }

        /* 偏好设置页面样式 */
        @-moz-document url-prefix("about:preferences") {
          :root {
            --zen-colors-tertiary: #${base00} !important;
            --in-content-text-color: #${base05} !important;
            --link-color: #${highlightColor} !important;
            --link-color-hover: rgb(185, 233, 181) !important;
            --zen-colors-primary: #${base02} !important;
            --in-content-box-background: #${base02} !important;
            --zen-primary-color: #${highlightColor} !important;
          }
          groupbox, moz-card { background: #${base01} !important; }
          button, groupbox menulist { background: #${base02} !important; color: #${base05} !important; }
          .main-content { background-color: #${base00} !important; }
          .identity-color-blue { --identity-tab-color: #${base0D} !important; --identity-icon-color: #${base0D} !important; }
          .identity-color-turquoise { --identity-tab-color: #${base0C} !important; --identity-icon-color: #${base0C} !important; }
          .identity-color-green { --identity-tab-color: #${highlightColor} !important; --identity-icon-color: #${highlightColor} !important; }
          .identity-color-yellow { --identity-tab-color: #${base0A} !important; --identity-icon-color: #${base0A} !important; }
          .identity-color-orange { --identity-tab-color: #${base09} !important; --identity-icon-color: #${base09} !important; }
          .identity-color-red { --identity-tab-color: #${base08} !important; --identity-icon-color: #${base08} !important; }
          .identity-color-pink { --identity-tab-color: #${base0F} !important; --identity-icon-color: #${base0F} !important; }
          .identity-color-purple { --identity-tab-color: #${base0E} !important; --identity-icon-color: #${base0E} !important; }
        }

        /* 插件页面样式 */
        @-moz-document url-prefix("about:addons") {
          :root {
            --zen-dark-color-mix-base: #${base00} !important;
            --background-color-box: #${base01} !important;
          }
        }

        /* 安全页面样式 */
        @-moz-document url-prefix("about:protections") {
          :root {
            --zen-primary-color: #${base01} !important;
            --social-color: #${base0E} !important;
            --coockie-color: #${base0C} !important;
            --fingerprinter-color: #${base0A} !important;
            --cryptominer-color: #${base06} !important;
            --tracker-color: #${highlightColor} !important;
            --in-content-primary-button-background-hover: #${base03} !important;
            --in-content-primary-button-text-color-hover: #${base05} !important;
            --in-content-primary-button-background: #${base03} !important;
            --in-content-primary-button-text-color: #${base05} !important;
          }
          .card { background-color: #${base02} !important; }
        }

        /* 错误与成功提示 */
        .success-message {
          background-color: #a6e3a1 !important; /* base0B */
          color: #${base00} !important;
          padding: 10px;
        }

        .error-message {
          background-color: #f38ba8 !important; /* base08 */
          color: #${base00} !important;
          padding: 10px;
        }

        /* 动画与过渡效果 */
        button, .button {
          transition: background-color 0.3s ease, border-color 0.3s ease;
        }

        /* 身份标识和选项卡样式 */
        .identity-color-blue { --identity-tab-color: #${base0D} !important; }
        .identity-color-green { --identity-tab-color: #${highlightColor} !important; }
        .identity-color-yellow { --identity-tab-color: #${base0A} !important; }
      }
    '';
  };
}
