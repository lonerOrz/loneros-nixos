{
  pkgs,
  config,
  ...
}:
let
  homepage = "https://start.duckduckgo.com";
in
{
  imports = [ ./theme.nix ];

  programs.qutebrowser = {
    enable = true;

    quickmarks = {
      clash = "https://metacubex.github.io/metacubexd/#/setup?http=true&hostname=127.0.0.1&port=9097&secret=123456";
      mynixos = "https://mynixos.com";
      github = "https://github.com";
      openwrt = "http://192.168.100.1";
      chatgpt = "https://chat.openai.com/";
      nixvim = "https://nix-community.github.io/nixvim/";
      hyprland = "https://wiki.hyprland.org/";
      nerdfont = "https://www.nerdfonts.com/cheat-sheet";
      youtube = "https://youtube.com/";
    };

    searchEngines = {
      "DEFAULT" = "https://duckduckgo.com/?q={}&ia=web";
      "nix" = "https://mynixos.com/search?q={}";
    };

    settings = {
      url = {
        default_page = "${homepage}";
        start_pages = [ "${homepage}" ];
      };
      colors = {
        webpage.preferred_color_scheme = "dark"; # Enable dark mode for websites that support it
      };
      statusbar.show = "in-mode";
      completion = {
        height = "30%";
        open_categories = [
          "history"
          "bookmarks"
          "quickmarks"
        ];
        scrollbar = {
          padding = 0;
          width = 0;
        };
        show = "always";
        shrink = true;
        timestamp_format = "";
        web_history.max_items = 7;
      };
      content = {
        autoplay = false;
        javascript.clipboard = "access";
        javascript.enabled = true;
        webgl = true;
        pdfjs = true;
      };
      downloads = {
        position = "bottom";
        remove_finished = 0;
      };
      # 配置提示模式（用于键盘导航链接）的样式
      hints = {
        radius = 1;
      };
      scrolling = {
        bar = "never";
        smooth = true;
      };
      tabs = {
        show = "multiple";
        position = "top";
        width = "30%";
        background = true;
        last_close = "close";
        mode_on_change = "restore";
        close_mouse_button = "right";
      };
      zoom.default = "90%";
      qt.force_software_rendering = "none"; # none, qt, software-opengl, chromium
    };

    keyBindings = {
      normal = {
        "gh" = "open ${homepage}";

        " p" = "tab-move -";
        " n" = "tab-move +";
        " w" = "tab-close";

        " 1" = "tab-focus 1";
        " 2" = "tab-focus 2";
        " 3" = "tab-focus 3";
        " 4" = "tab-focus 4";
        " 5" = "tab-focus 5";
        " 6" = "tab-focus 6";
        " 7" = "tab-focus 7";
        " 8" = "tab-focus 8";
        " 9" = "tab-focus 9";
        " 0" = "tab-focus 10";

        "<Ctrl-w>" = "tab-close";
        "<Ctrl-n>" = "open -w";

        "<Ctrl-1>" = "tab-focus 1";
        "<Ctrl-2>" = "tab-focus 2";
        "<Ctrl-3>" = "tab-focus 3";
        "<Ctrl-4>" = "tab-focus 4";
        "<Ctrl-5>" = "tab-focus 5";
        "<Ctrl-6>" = "tab-focus 6";
        "<Ctrl-7>" = "tab-focus 7";
        "<Ctrl-8>" = "tab-focus 8";
        "<Ctrl-9>" = "tab-focus 9";
        "<Ctrl-0>" = "tab-focus 10";
      };

      command = {
        "<Ctrl-w>" = "tab-close";
        "<Ctrl-n>" = "open -w";
        "<Ctrl-1>" = "tab-focus 1";
        "<Ctrl-2>" = "tab-focus 2";
        "<Ctrl-3>" = "tab-focus 3";
        "<Ctrl-4>" = "tab-focus 4";
        "<Ctrl-5>" = "tab-focus 5";
        "<Ctrl-6>" = "tab-focus 6";
        "<Ctrl-7>" = "tab-focus 7";
        "<Ctrl-8>" = "tab-focus 8";
        "<Ctrl-9>" = "tab-focus 9";
        "<Ctrl-0>" = "tab-focus 10";
      };

      insert = {
        "<Ctrl-w>" = "tab-close";
        "<Ctrl-n>" = "open -w";
        "<Ctrl-1>" = "tab-focus 1";
        "<Ctrl-2>" = "tab-focus 2";
        "<Ctrl-3>" = "tab-focus 3";
        "<Ctrl-4>" = "tab-focus 4";
        "<Ctrl-5>" = "tab-focus 5";
        "<Ctrl-6>" = "tab-focus 6";
        "<Ctrl-7>" = "tab-focus 7";
        "<Ctrl-8>" = "tab-focus 8";
        "<Ctrl-9>" = "tab-focus 9";
        "<Ctrl-0>" = "tab-focus 10";
      };
    };

    extraConfig = ''
      config.unbind("gm")
      config.unbind("gd")
      config.unbind("gb")
      config.unbind("tl")
      config.unbind("gt")

      c.tabs.padding = {"bottom": 6, "left": 7, "right": 7, "top": 6}
      c.statusbar.padding = {"bottom": 6, "left": 7, "right": 7, "top": 6}

      config.load_autoconfig(True)

      config.source("theme.config.py")
    '';
  };
}
