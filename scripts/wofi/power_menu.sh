#!/bin/bash

choice=$(echo -e "Shutdown\nReboot\nSuspend\nLogout" | wofi --dmenu --lines "5")

case "$choice" in
"Shutdown")
  systemctl poweroff
  ;;
"Reboot")
  systemctl reboot
  ;;
"Suspend")
  systemctl suspend
  ;;
"Logout")
  hyprctl dispatch exit
  ;;
*)
  exit 0
  ;;
esac
