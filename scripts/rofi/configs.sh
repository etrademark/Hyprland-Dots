#!/bin/bash

DIR="$HOME/.config/hypr/Configs/"

files="animations.conf\nkeybinds.conf\nsettings.conf\nstartup.conf\nwindowRules.conf"
selected=$(echo -e "$files" | rofi -dmenu -p "Select file:")
textEditor="nvim"

if [ -n "$selected" ]; then
  kitty -e $textEditor "${DIR}${selected}"
fi
