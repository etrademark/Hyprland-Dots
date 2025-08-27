#!/bin/bash

dir="$HOME/.config/hypr/conf/"

files="animations.conf\nkeybinds.conf\nsettings.conf\nstartup.conf\nwindowRules.conf"
selected=$(echo -e "$files" | rofi -dmenu -p "Select file")

if [ -n "$selected" ]; then
  kitty -e $EDITOR "$HOME/.config/hypr/conf/${selected}"
fi
