#!/usr/bin/env bash

respond=$(echo -e "Shutdown\nRestart\nCancel" | fuzzel --dmenu --lines=3 --width=10 --prompt='')

if [ "$respond" = "Shutdown" ]; then
  echo "shutdown"
  shutdown -h now
elif [ "$respond" = "Restart" ]; then
  echo "restart"
  reboot
else
  notify-send "cancel shutdown"
fi
