#!/bin/bash

if [[ $3 == "mic" ]]; then
  object="source"
  object2="SOURCE"
  thing="Microphone"
else
  object="sink"
  object2="SINK"
  thing="Speaker"
fi

function get_volume() {
  volume=$(pactl get-$object-volume @DEFAULT_$object2@ | grep -oP '\d+(?=%)' | head -n 1)
  icon=$(pactl get-$object-mute @DEFAULT_$object2@ | grep -oP '(?<=Mute: ).*')

  if [ $icon == "yes" ]; then
    icon="🔇"
  elif [ $volume -gt 100 ]; then
    icon="📢"
  elif [ $volume -ge 70 ]; then
    icon="🔊"
  elif [ $volume -ge 40 ]; then
    icon="🔉"
  elif [ $volume -gt 0 ]; then
    icon="🔈"
  else
    icon="🔇"
  fi
}

function notify() {
  notify-send -h string:x-canonical-private-synchronous:volume_notif "${thing} volume: ${volume}%" "${icon}" -h int:value:"${volume}" -e
}

case "${1}" in
"raise")
  pactl set-$object-volume @DEFAULT_$object2@ +$2%
  get_volume
  notify
  ;;
"lower")
  pactl set-$object-volume @DEFAULT_$object2@ -$2%
  get_volume
  notify
  ;;
"toggle")
  pactl set-$object-mute @DEFAULT_$object2@ toggle
  get_volume
  notify
  ;;
*)
  echo -e "Usage:\n $0 {raise|lower|toggle} <value> [mic]\nIf toggling, <value> should be anything."
  ;;
esac
