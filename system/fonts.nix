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
    };
  };
}
