{ config,
  lib,
  username,
  pkgs,
  ...
}: let
  fcitx5-pinyin-zhwiki = pkgs.callPackage ../pkgs/fcitx5-pinyin-zhwiki { };
in
{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    inputMethod = {
      #enabled = "fcitx5";
      type = "fcitx5";
      enable = true;

      fcitx5 = {
        # waylandFrontend = true; #
        # plasma6Support = true; #不用kde6 貌似不用启用
        addons = with pkgs; [
          fcitx5-chinese-addons
          fcitx5-mozc
          fcitx5-gtk #  Fcitx5 gtk im module and glib based dbus client library
          fcitx5-material-color
          fcitx5-pinyin-zhwiki
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
            "Groups/0/Items/1".Name = "pinyin";
            GroupOrder."0" = "Default";
          };
        };
      };
    };
  };

}

