#!/bin/bash

# Function to get the current volume
get_current_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//'
}

# Function to display a notification
notify_volume() {
  local volume=$1
  dunstify -t 3000 -a "Volume" -h int:value:"$volume" -h string:synchronous:volume "Volume: $volume%"
}

# Check command line arguments
case "$1" in
up)
  pactl set-sink-volume @DEFAULT_SINK@ +5%
  new_volume=$(get_current_volume)
  notify_volume "$new_volume"
  ;;
down)
  pactl set-sink-volume @DEFAULT_SINK@ -5%
  new_volume=$(get_current_volume)
  notify_volume "$new_volume"
  ;;
mute)
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  if [ "$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')" == "yes" ]; then
    dunstify -t 3000 -a "Volume" -h string:synchronous:volume "Volume Muted"
  else
    new_volume=$(get_current_volume)
    notify_volume "$new_volume"
  fi
  ;;
*)
  echo "Usage: $0 {up|down|mute}"
  exit 1
  ;;
esac
