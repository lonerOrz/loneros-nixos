{ config, ... }:
let
  # 定义 Stylix 颜色变量，确保正确嵌入字符串
  base00 = "#${config.lib.stylix.colors.base00}";
  base01 = "#${config.lib.stylix.colors.base01}";
  base02 = "#${config.lib.stylix.colors.base02}";
  base03 = "#${config.lib.stylix.colors.base03}";
  base04 = "#${config.lib.stylix.colors.base04}";
  base05 = "#${config.lib.stylix.colors.base05}";
  base06 = "#${config.lib.stylix.colors.base06}";
  base07 = "#${config.lib.stylix.colors.base07}";
  base08 = "#${config.lib.stylix.colors.base08}";
  base09 = "#${config.lib.stylix.colors.base09}";
  base0A = "#${config.lib.stylix.colors.base0A}";
  base0B = "#${config.lib.stylix.colors.base0B}";
  base0C = "#${config.lib.stylix.colors.base0C}";
  base0D = "#${config.lib.stylix.colors.base0D}";
  base0E = "#${config.lib.stylix.colors.base0E}";
  base0F = "#${config.lib.stylix.colors.base0F}";
in
{
  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        # battery = true; # 显示电池小组件
        process_memory_as_value = true; # 显示内存值为具体数值
        tree = true; # 进程显示为树状模式
        network_use_log = false; # 不使用对数刻度显示网络流量
        enable_gpu = true; # 显示 GPU 信息
        enable_cache_memory = true; # 显示缓存和缓冲区内存
      };

      processes = {
        columns = [
          "PID"
          "Name"
          "CPU%"
          "Mem%"
          "R/s"
          "W/s"
          "T.Read"
          "T.Write"
          "User"
          "State"
          "GMem%"
          "GPU%"
        ];
      };

      styles = {
        tables = {
          headers = {
            color = base05;
          };
        };

        cpu = {
          all_entry_color = base05;
          avg_entry_color = base09;
          cpu_core_colors = [
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
            base07
            base06
          ];
        };

        memory = {
          ram_color = base0A;
          swap_color = base0E;
          gpu_colors = [
            base08
            base09
            base0A
            base0B
            base0C
            base0D
          ];
          arc_color = base0D;
        };

        network = {
          rx_color = base0A;
          tx_color = base0E;
        };

        widgets = {
          widget_title = {
            color = base0A;
          };
          border_color = base03;
          selected_border_color = base0D;
          text = {
            color = base05;
          };
          selected_text = {
            color = base00;
            bg_color = base0D;
          };
        };

        graphs = {
          graph_color = base03;
        };

        battery = {
          high_battery_color = base0A;
          medium_battery_color = base0B;
          low_battery_color = base08;
        };
      };
    };
  };
}
