{
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
          zhSC = "LXGW WenKai"; # 简体中文
          zhTC = "LXGW WenKai"; # 繁体中文
          jaJP = "Noto Sans CJK JP"; # 日文
        in
        ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">

          <fontconfig>

            <selectfont>
              <rejectfont>
                <pattern>
                  <patelt name="family">
                    <string>DejaVu Sans</string>
                  </patelt>
                </pattern>
              </rejectfont>
            </selectfont>

            <match target="pattern">
              <test name="lang" compare="eq">
                <string>zh-cn</string>
              </test>
              <test name="family">
                <string>sans-serif</string>
              </test>
              <edit name="family" mode="prepend" binding="strong">
                <string>${zhSC}</string>
              </edit>
            </match>

            <match target="pattern">
              <test name="lang" compare="eq">
                <string>zh-tw</string>
              </test>
              <test name="family">
                <string>sans-serif</string>
              </test>
              <edit name="family" mode="prepend" binding="strong">
                <string>${zhTC}</string>
              </edit>
            </match>

            <match target="pattern">
              <test name="lang" compare="eq">
                <string>ja</string>
              </test>
              <test name="family">
                <string>sans-serif</string>
              </test>
              <edit name="family" mode="prepend" binding="strong">
                <string>${jaJP}</string>
              </edit>
            </match>

          </fontconfig>
        '';
    };
  };
}
