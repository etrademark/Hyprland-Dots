#!/bin/bash

if [[ $3 == "mic" ]]; then
  object="SOURCE"
  thing="Microphone"
else
  object="SINK"
  thing="Speaker"
fi

function get_volume() {
  volume=$(wpctl get-volume @DEFAULT_$object@ | grep -oP '\d+(\.\d+)?' | head -1)
  volume=$(printf "%.0f" "$(echo "scale=0; $volume * 100" | bc)")

  if [[ $(wpctl get-volume @DEFAULT_$object@) == *"MUTED"* ]]; then icon=true; fi

  if [ $icon ]; then
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
  notify-send -h string:x-canonical-private-synchronous:volume_notif "${thing} volume: ${volume}%" "${icon}" -h int:value:"${volume}" -e -u low
}

if [[ $1 == "raise" ]]; then
  operator="+"
elif [[ $1 == "lower" ]]; then operator="-"; fi

case "${1}" in
"raise" | "lower")
  wpctl set-volume @DEFAULT_$object@ $2%$operator
  get_volume
  notify
  ;;
"toggle")
  wpctl set-mute @DEFAULT_$object@ toggle
  get_volume
  notify
  ;;
*)
  echo -e "Usage:\n $0 {raise|lower|toggle} <value> [mic]\nIf toggling, <value> should be anything."
  ;;
esac
