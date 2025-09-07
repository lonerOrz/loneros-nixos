{ pkgs, ... }:
{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    inputMethod = {
      type = "fcitx5";
      enable = true;

      fcitx5 = {
        waylandFrontend = true;
        # plasma6Support = true; #不用kde6 貌似不用启用
        addons = with pkgs; [
          fcitx5-gtk # Fcitx5 gtk im module and glib based dbus client library
          kdePackages.fcitx5-qt
          fcitx5-material-color

          # Rime
          (fcitx5-rime.override {
            rimeDataPkgs = [
              rime-ice
              rime-moegirl
              rime-wanxiang
            ];
          })

          # pinyin
          # fcitx5-chinese-addons
          # fcitx5-pinyin-zhwiki # 中文维基百科词条
          # fcitx5-pinyin-moegirl # 萌娘百科词条
        ];
        #ignoreUserConfig = true; #启用不光个人设置无效，个人词库也会无法保存
        settings = {
          addons = {
            classicui.globalSection.Theme = "macOS-dark";
            classicui.globalSection.DarkTheme = "macOS-dark";
            pinyin.globalSection = {
              PageSize = 9;
              CloudPinyinEnabled = "True";
              CloudPinyinIndex = 2;
            };
            cloudpinyin.globalSection = {
              Backend = "Baidu";
            };
          };
          #globalOptions = { "Hotkey/TriggerKeys" = { "0" = "Alt+space"; }; };
          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "Rime";
            GroupOrder."0" = "Default";
          };
        };
      };
    };
  };
}
