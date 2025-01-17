#!/usr/bin/env bash

respond=$(echo -e "Shutdown\nRestart\nCancel" | fuzzel --dmenu --lines=3 --width=10 --prompt='')

if [ "$respond" = " Shutdown" ]; then
  echo "shutdown"
  sudo shutdown now
elif [ "$respond" = " Restart" ]; then
  echo "restart"
  sudo reboot
else
  notify-send "cancel shutdown"
fi
