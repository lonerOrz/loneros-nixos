{
  pkgs,
  ...
}:
{
  # FONTS
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    noto-fonts-cjk-sans
    jetbrains-mono
    font-awesome
    terminus_font
    #(nerdfonts.override {fonts = ["JetBrainsMono"];}) # stable banch
    nerd-fonts.jetbrains-mono # unstable
    nerd-fonts.fira-code # unstable
    lxgw-wenkai-screen # 屏幕显示优化版
    lxgw-wenkai # wenkai mono
    victor-mono
    nerd-fonts.fantasque-sans-mono # unstable
    nerd-fonts.iosevka # rofi
  ];
}
