{
  lib,
  pkgs,
  ...
}:
{
  fonts = {
    packages = with pkgs; [
      # 通用字体（支持多语言）
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # 编程 / 等宽字体
      jetbrains-mono
      fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.iosevka
      nerd-fonts.caskaydia-mono

      # 中文 / 混合字体
      lxgw-wenkai-screen
      lxgw-wenkai

      # 其他好看的字体（选项）
      roboto
      inter-nerdfont
      victor-mono
      material-symbols
      maple-mono.NF-CN
      nerd-fonts.fantasque-sans-mono
    ];

    # 不让系统自动安装默认字体（这样就不会自动装 DejaVu）
    enableDefaultPackages = false;

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif"
          "emoji"
        ];
        sansSerif = [
          "Inter Nerd Font"
          "Noto Sans"
          "emoji"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "FiraCode Nerd Font"
          "Iosevka Nerd Font"
          "emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
      localConf =
        let
          languageFonts = {
            "zh-cn" = {
              sans-serif = "LXGW WenKai";
              serif = "LXGW WenKai";
              monospace = "Maple Mono NF CN";
            };

            "ja" = {
              sans-serif = "Noto Sans CJK JP";
              serif = "Noto Serif";
              monospace = "Maple Mono NF CN";
            };

            "en" = {
              sans-serif = "Inter Nerd Font";
              serif = "Noto Serif";
              monospace = "Maple Mono NF CN";
            };

            "emoji" = {
              sans-serif = "Noto Color Emoji";
              serif = "Noto Color Emoji";
              monospace = "Noto Color Emoji";
            };
          };

          rejectFonts = [
            "DejaVu Sans"
            "DejaVu Serif"
            "DejaVu Sans Mono"
            "Source Han Sans"
            "WenQuanYi Zen Hei"
          ];

          uiFamilies = {
            "system-ui" = "Inter Nerd Font";
            "ui-sans-serif" = "Inter Nerd Font";
            "ui-monospace" = "Maple Mono NF CN";
          };

          appFonts = {
            "chrome" = {
              "sans-serif" = "Inter Nerd Font";
              "monospace" = "Maple Mono NF CN";
            };
            "firefox" = {
              "sans-serif" = "Inter Nerd Font";
              "monospace" = "Maple Mono NF CN";
            };
            "code" = {
              "sans-serif" = "Inter Nerd Font";
              "monospace" = "Maple Mono NF CN";
            };
          };

          generatedRules = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              lang: families:
              lib.concatStringsSep "\n" (
                lib.mapAttrsToList (family: font: ''
                  <match target="pattern">
                    <test name="lang" compare="eq">
                      <string>${lang}</string>
                    </test>
                    <test name="family">
                      <string>${family}</string>
                    </test>
                    <edit name="family" mode="prepend" binding="strong">
                      <string>${font}</string>
                    </edit>
                  </match>
                '') families
              )
            ) languageFonts
          );

          genRejectRules = lib.concatStringsSep "\n" (
            map (f: ''
              <rejectfont>
                <pattern><patelt name="family"><string>${f}</string></patelt></pattern>
              </rejectfont>
            '') rejectFonts
          );

          genUIRules = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (family: font: ''
              <match target="pattern">
                <test name="family"><string>${family}</string></test>
                <edit name="family" mode="prepend" binding="strong">
                  <string>${font}</string>
                </edit>
              </match>
            '') uiFamilies
          );

          genAppRules = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              prog: families:
              lib.concatStringsSep "\n" (
                lib.mapAttrsToList (family: font: ''
                  <match target="pattern">
                    <test name="prgname" compare="eq"><string>${prog}</string></test>
                    <test name="family"><string>${family}</string></test>
                    <edit name="family" mode="prepend" binding="strong">
                      <string>${font}</string>
                    </edit>
                  </match>
                '') families
              )
            ) appFonts
          );

          emojiFallback =
            let
              ef = languageFonts."emoji";
            in
            ''
              <alias>
                <family>sans-serif</family>
                <prefer><family>${ef."sans-serif"}</family></prefer>
              </alias>
              <alias>
                <family>serif</family>
                <prefer><family>${ef."serif"}</family></prefer>
              </alias>
              <alias>
                <family>monospace</family>
                <prefer><family>${ef."monospace"}</family></prefer>
              </alias>
            '';
        in
        ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">

          <fontconfig>

            <selectfont>
              ${genRejectRules}
            </selectfont>

            ${generatedRules}

            ${genUIRules}

            ${genAppRules}

            ${emojiFallback}

          </fontconfig>
        '';
    };
  };
}
