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
        battery = true; # 显示电池小组件
        process_memory_as_value = true; # 显示内存值为具体数值
        tree = false; # 进程显示为树状模式
        network_use_log = false; # 不使用对数刻度显示网络流量
        enable_gpu = true; # 显示 GPU 信息
        enable_cache_memory = true; # 显示缓存和缓冲区内存
      };

      # 进程小组件设置
      processes = {
        columns = ["PID" "Name" "CPU%" "Mem%" "R/s" "W/s" "T.Read" "T.Write" "User" "State" "GMem%" "GPU%"];
      };

      # CPU 小组件设置
      cpu = {
        all_entry_color = base08;
        avg_entry_color = base09;
        cpu_core_colors = [base0A base0B base0C base0D base0E base0F base07 base06];
      };

      # 内存小组件设置
      memory = {
        ram_color = base0A;
        cache_color = base0C;
        swap_color = base0E;
        arc_color = base0D;
        gpu_colors = [base08 base09 base0A base0B base0C base0D];
      };

      # 网络小组件设置
      network = {
        rx_color = base0B;
        tx_color = base0D;
        rx_total_color = base0A;
        tx_total_color = base0C;
      };

      # 电池小组件设置
      battery = {
        high_battery_color = base0B;
        medium_battery_color = base0A;
        low_battery_color = base08;
      };

      # 表格样式设置
      tables = {
        headers = { color = base05; bold = true; };
      };

      # 图表样式设置
      graphs = {
        graph_color = base03;
        legend_text = { color = base04; };
      };

      # 小组件样式设置
      widgets = {
        border_color = base03;
        selected_border_color = base0D;
        widget_title = { color = base05; };
        text = { color = base05; };
        selected_text = { color = base00; bg_color = base0D; };
        disabled_text = { color = base03; };
      };
    };
  };
}
