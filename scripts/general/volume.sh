#!/bin/bash

arg1=$1

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
  if [[ $arg1 == "toggle" ]]; then
    muted=$(pactl get-$object-mute @DEFAULT_$object2@ | grep -oP '(?<=Mute: ).*')
    if [[ $muted == "yes" ]]; then
      muted="Muted."
    else
      muted="Unmuted."
    fi
  else
    muted=""
  fi
}

function notify() {
  notify-send -h string:x-canonical-private-synchronous:volume_notif "${thing} volume: ${volume}%" "${muted}" -h int:value:"${volume}" -e
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
