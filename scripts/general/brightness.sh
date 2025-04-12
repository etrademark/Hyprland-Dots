#!/bin/bash

function get_brightness() {
  brightness=$(($(brightnessctl get) * 100 / $(brightnessctl max)))
  echo $brightness
}

case $1 in
"raise")
  brightnessctl set +$2% >/dev/null
  ;;
"lower")
  brightnessctl set $2%- >/dev/null
  ;;
*)
  echo -e "Usage:\n $0 {get|up|down}"
  exit 1
  ;;
esac

get_brightness
notify-send -h string:x-canonical-private-synchronous:volume_notif "Brightness set to ${brightness}%" -e -h int:value:"${brightness}"
