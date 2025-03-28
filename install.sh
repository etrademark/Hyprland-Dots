#!/bin/bash
tmux start-server

### Variables
installDir="$HOME/temp"
mkdir -p $installDir/logs

# ANSI Color codes
RESET='\e[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
LIGHT_YELLOW='\e[38;5;229m'
ORANGE='\e[38;5;214m'
CYAN='\033[0;36m'
WARNING="${YELLOW}[${ORANGE}!${YELLOW}]${LIGHT_YELLOW} "
ERROR="${RED}[${ORANGE}!${RED}] "
NOTE="${LIGHT_YELLOW}[${RESET}!${LIGHT_YELLOW}]${RESET} "
printf "${WARNING}This script is still in development. Please use with caution.${RESET}\n"

if hash paru 2>/dev/null; then
  helper='paru'
elif hash yay 2>/dev/null; then
  helper='yay'
else
  noHelper=true
fi

cancel() {
  if [[ $? = 1 || $? = 255 ]]; then
    printf "${RED}User canceled, stopping...${RESET}\n"
    exit 1
  fi
}

printf "${NOTE}Installing required packages and setting up permissions.\n"
sudo pacman -Sy --noconfirm --needed base-devel cargo git tmux

installOptions=$(whiptail --title "Hyprland-Dots install script" --checklist "Choose options to install or configure" 15 100 5 \
  "zsh-powerlevel10k" "Configure and change shell to zsh with powerlevel10k theming" off \
  "lazyvim" "Install LazyVim and neovim text editor (command: nvim)" off \
  "hyprland" "Plain Hyprland without dotfiles (unless previously configured)" off \
  "dotfiles" "Configure Hyprland with etrademark's dotfiles" off \
  "languages" "Install some additional programming languages" off \
  2>&1 >/dev/tty)
cancel

echo $installOptions

if $(hostnamectl | grep -q "ASUSTeK COMPUTER INC."); then
  if $(hostnamectl) | grep -q "Laptop"; then
    rog=$(whiptail --title "ROG" --yesno "You seem to have a ASUS device.\nDo you want to install asus-linux and supergfxctl (recommended for ROG and TUF laptops)?" 15 50)
  fi
fi

if [ "$noHelper" = true ]; then
  aurHelper=$(whiptail --title "AUR Helper not installed." --radiolist \
    "Choose an AUR Helper:" 15 50 2 \
    "paru" "Install Paru" on \
    "yay" "Install Yay" off \
    2>&1 >/dev/tty)
  cancel

  helper=$aurHelper

  printf "${NOTE}Installing AUR Helper ${helper}.\n"
  git clone "https://aur.archlinux.org/${helper}-bin.git" $installDir/$helper
  cd $installDir/$helper
  makepkg -si --noconfirm >"$installDir/logs/$helper.log" 2>&1
  if [ $? -ne 0 ]; then
    printf "${ERROR}Failed to install ${helper}. Check the log in ${CYAN}$installDir/logs/${HELPER}.log${RESET}\n"
  fi

  cd .. && rm -rf $installDir/$helper
fi

$helper -Sy --noconfirm hyprland wget curl kitty unzip
$helper -Sy --noconfirm ripgrep stylua lua51 luarocks hererocks fd lazygit fzf ghostscript
