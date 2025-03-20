{ config, ... }:
let
  # 定义 Base16 颜色变量
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
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "custom";
      theme_background = false;
      truecolor = true;
      force_tty = false;
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      vim_keys = false;
      rounded_corners = true;
      graph_symbol = "braille";
      shown_boxes = "cpu mem net";
      update_ms = 2000;
      proc_sorting = "cpu lazy";
      proc_colors = true;
      proc_gradient = true;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      cpu_invert_lower = true;
      show_uptime = true;
      check_temp = true;
      temp_scale = "celsius";
      base_10_sizes = false;
      show_cpu_freq = true;
      clock_format = "%X";
      background_update = true;
      mem_graphs = true;
      zfs_arc_cached = true;
      show_swap = true;
      show_disks = true;
      only_physical = true;
      show_io_stat = true;
      net_download = 100;
      net_upload = 100;
      net_auto = true;
      net_sync = true;
      show_battery = true;
      show_battery_watts = true;
      log_level = "WARNING";
      gpu_mirror_graph = true;
    };
  };

  home.file.".config/btop/themes/custom.theme" = {
    text = ''
      # Main background and text colors
      theme[main_bg] = "${base00}"
      theme[main_fg] = "${base05}"
      theme[title] = "${base05}"
      theme[hi_fg] = "${base0D}"

      # Process box selected item
      theme[selected_bg] = "${base02}"
      theme[selected_fg] = "${base0D}"

      # Inactive/disabled text and graph text
      theme[inactive_fg] = "${base03}"
      theme[graph_text] = "${base06}"

      # Meter background and process misc colors
      theme[meter_bg] = "${base02}"
      theme[proc_misc] = "${base06}"

      # Box outline colors
      theme[cpu_box] = "${base0E}"
      theme[mem_box] = "${base0B}"
      theme[net_box] = "${base08}"
      theme[proc_box] = "${base0D}"
      theme[div_line] = "${base04}"

      # Temperature graph colors (Green -> Yellow -> Red)
      theme[temp_start] = "${base0B}"
      theme[temp_mid] = "${base0A}"
      theme[temp_end] = "${base08}"

      # CPU graph colors (Teal -> Lavender)
      theme[cpu_start] = "${base0C}"
      theme[cpu_mid] = "${base0D}"
      theme[cpu_end] = "${base0E}"

      # Memory/Disk meter colors
      theme[free_start] = "${base0B}"
      theme[free_mid] = "${base0D}"
      theme[free_end] = "${base0C}"
      theme[cached_start] = "${base0D}"
      theme[cached_mid] = "${base0C}"
      theme[cached_end] = "${base0E}"
      theme[available_start] = "${base09}"
      theme[available_mid] = "${base08}"
      theme[available_end] = "${base0F}"
      theme[used_start] = "${base0B}"
      theme[used_mid] = "${base0C}"
      theme[used_end] = "${base0D}"

      # Network graph colors (Download and Upload)
      theme[download_start] = "${base09}"
      theme[download_mid] = "${base08}"
      theme[download_end] = "${base0F}"
      theme[upload_start] = "${base0B}"
      theme[upload_mid] = "${base0C}"
      theme[upload_end] = "${base0D}"

      # Process box gradient colors (Blue -> Mauve)
      theme[process_start] = "${base0D}"
      theme[process_mid] = "${base0E}"
      theme[process_end] = "${base0F}"
    '';
  };
}
