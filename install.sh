#!/bin/bash
tmux start-server

### Variables
installDir="$HOME/temp"
mkdir -p $installDir/logs

powerlevel10k="zsh"
hyprland="hyprland kitty thunar blueman networkmanager network-manager-applet pulseaudio pavucontrol alsa-firmware cava btop waybar"
lazyvim="neovim ripgrep stylua lua51 luarocks hererocks fd lazygit fzf ghostscript"

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
printf "${WARNING}This script is still in development. Please use it with caution.${RESET}\n"

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
sudo pacman -Sy --noconfirm --needed base-devel cargo git wget curl unzip

installOptions=$(whiptail --title "Hyprland-Dots install script" --checklist "Choose options to install or configure" 15 100 5 \
  "zim-powerlevel10k" "Configure and change shell to zsh (+ zim) with powerlevel10k theming" off \
  "lazyvim" "Install LazyVim and neovim text editor (command: nvim)" off \
  "hyprland" "Plain Hyprland without dotfiles (unless previously configured)" off \
  "dotfiles" "Configure Hyprland with etrademark's dotfiles" off \
  "languages" "Install some additional programming languages" off \
  2>&1 >/dev/tty)
cancel

echo $installOptions

if $(hostnamectl | grep -q "ASUSTeK COMPUTER INC."); then
  if $(hostnamectl) | grep -q "Laptop"; then
    rog=$(whiptail --title "ROG" --yesno "You seem to have an ASUS device.\nDo you want to install asus-linux and supergfxctl (recommended for ROG and TUF laptops)?" 15 50)
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

  printf "${NOTE}Installing the AUR Helper ${helper}.\n"
  git clone "https://aur.archlinux.org/${helper}-bin.git" $installDir/$helper
  cd $installDir/$helper
  makepkg -si --noconfirm >"$installDir/logs/$helper.log" 2>&1
  if [ $? -ne 0 ]; then
    printf "${ERROR}Failed to install ${helper}. Check the log in ${CYAN}$installDir/logs/${HELPER}.log${RESET}\n"
  fi

  cd .. && rm -rf $installDir/$helper
fi

if [[ ! $installOptions == *"zim-powerlevel10k"* ]]; then
  powerlevel10k=null
else
  printf "${NOTE}zsh and powerlevel10k will be installed.\n"
fi

if [[ ! $installOptions == *"hyprland"* ]]; then
  hyprland=null
else
  printf "${NOTE}Hyprland will be installed.\n"
fi

if [[ ! $installOptions == *"lazyvim"* ]]; then
  lazyvim=null
else
  printf "${NOTE}LazyVim will be installed.\n"
fi

$helper -Sy --noconfirm --needed $powerlevel10k $hyprland $lazyvim

# Poorly written script by me (;
if [ -n "$lazyvim" ]; then
  printf "${NOTE}Installing LazyVim.\n"
  curl -sL https://raw.githubusercontent.com/etrademark/lazyvim/master/install.sh | bash
fi

if [ -n "$powerlevel10k" ]; then
  printf "${NOTE}Setting up zsh, zim and powerlevel10k.\n"
  zsh

  chsh -s /usr/bin/zsh
  if ! hash zimfw 2>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
  fi
  echo "zmodule romkatv/powerlevel10k --use degit" >>$HOME/.zimrc
  zimfw install
fi
