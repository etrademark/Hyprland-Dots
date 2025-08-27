#!/bin/bash

grim -g "$(slurp)" "${HOME}/Pictures/screenshot-$(date +'%y-%m-%d-%m-%s').png" &&
  wl-copy <"${HOME}/Pictures/screenshot-$(date +'%y-%m-%d-%m-%s').png"
