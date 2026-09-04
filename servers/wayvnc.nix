{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    tigervnc
    wayvnc
    (pkgs.writeShellScriptBin "vnc" ''
      #!/usr/bin/env bash

      # Stop existing instance if running
      if pkill -x wayvnc; then
        echo "Stopped existing wayvnc instance."
      fi

      # Configure headless Wayland environment
      export WLR_BACKENDS=headless
      export WLR_LIBINPUT_NO_DEVICES=1
      export WAYLAND_DISPLAY=wayland-1
      export WLR_OUTPUTS="DP-1:1920x1080@165"

      # Start wayvnc in background
      echo "Starting wayvnc on port 5901..."
      wayvnc 0.0.0.0 5901 -v --max-fps 165 --log-level debug &>/dev/null &

      sleep 0.5

      # Check execution status
      if pgrep -x wayvnc >/dev/null; then
        echo "wayvnc started successfully."
      else
        echo "Failed to start wayvnc."
        exit 1
      fi
    '')
  ];
}
