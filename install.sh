#!/bin/bash

### Variables
installDir="$HOME/temp"
mkdir -p $installDir/logs

powerlevel10k="zsh"
hyprland="hyprland noto-fonts kitty"
dotfiles="thunar blueman networkmanager network-manager-applet pulseaudio pavucontrol alsa-firmware cava btop waybar"
lazyvim="neovim nodejs npm ripgrep stylua lua51 luarocks hererocks fd lazygit fzf ghostscript"

# ANSI Color codes
RESET='\e[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
LIGHT_YELLOW='\e[38;5;229m'
ORANGE='\e[38;5;214m'
CYAN='\033[0;36m' # Directories
WARNING=" - ${YELLOW}[${ORANGE}!${YELLOW}]${LIGHT_YELLOW} "
ERROR=" - ${RED}[${ORANGE}!${RED}] "
NOTE=" - ${LIGHT_YELLOW}[${RESET}!${LIGHT_YELLOW}]${RESET} "
IMPORTANT=" - ${RESET}{${CYAN}IMPORTANT${RESET}}${YELLOW} "
echo -e "${WARNING}This script is still in development. Please use it with caution.${RESET}\n"

if hash paru 2>/dev/null; then
  helper='paru'
elif hash yay 2>/dev/null; then
  helper='yay'
else
  noHelper=true
fi

cancel() {
  if [[ $? = 1 || $? = 255 ]]; then
    echo -e "${RED}User canceled, stopping...${RESET}\n"
    exit 1
  fi
}

### Mildly distructive!!! Fix later
if [ -d $installDir ]; then
  whiptail --title "Hyprland-Dots" --yesno "Continuing will remove ${installDir}. Are you sure you want to continue?" 15 50
  chmod +w $installDir
  sudo rm -rf $installDir
  cancel
fi

echo -e "${NOTE}Installing required packages and setting up permissions.\n"
sudo pacman -Sy --noconfirm --needed base-devel cargo git wget curl unzip

installOptions=$(whiptail --title "Hyprland-Dots install script" --checklist "Choose options to install or configure" 15 100 5 \
  "zim-powerlevel10k" "Configure and change shell to zsh (+ zim) with powerlevel10k theming" off \
  "lazyvim" "Install LazyVim and neovim text editor (command: nvim)" off \
  "hyprland" "Plain Hyprland without dotfiles (unless previously configured)" off \
  "dotfiles" "Configure Hyprland with etrademark's dotfiles" off \
  "languages" "Install some additional programming languages and developer tools" off \
  2>&1 >/dev/tty)
cancel

echo $installOptions

if [[ $(hostnamectl = *"ASUSTeK COMPUTER INC."*); then
  if [[ $(hostnamectl) = *[Ll]"aptop"* ]]; then
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

  echo -e "${NOTE}Installing the AUR Helper ${helper}.\n"
  git clone "https://aur.archlinux.org/${helper}-bin.git" $installDir/$helper
  cd $installDir/$helper
  makepkg -si --noconfirm >"$installDir/logs/$helper.log" 2>&1
  if [ $? -ne 0 ]; then
    echo -e "${ERROR}Failed to install ${helper}. Check the log in ${CYAN}$installDir/logs/${HELPER}.log${RESET}\n"
  fi

  cd .. && rm -rf $installDir/$helper
fi

if [[ ! $installOptions == *"zim-powerlevel10k"* ]]; then
  powerlevel10k=""
else

  # --- ZSH ---
  # folder name for downloads and backups are ALWAYS zsh
  # --- --- ----

  echo -e "${NOTE}zsh and powerlevel10k will be installed.\n"
  echo -e "${NOTE}Setting up zsh, zim and powerlevel10k.\n"

  #chsh -s /usr/bin/zsh
  if ! hash zimfw 2>/dev/null; then
    curl -fsSL --create-dirs -o ~/.zim/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
  echo -e "${WARNING}Creating backups of your existing shell config files in {$CYAN}${HOME}${RESET} ending with ${CYAN}.bak${RESET}"
  sudo mv $HOME/.zshrc $HOME/.zshrc.bak
  mv $HOME/.zim $HOME/.zim.bak
  mv $HOME/.zimrc $HOME/.zimrc.bak

  echo debugtest
  cp -r ./.z* ${HOME}
fi

function hyprland() {
  if [[ ! $installOptions == *"hyprland"* ]]; then
    if [[ ! $installOptions == *"dotfiles"* ]]; then
      hyprland=""
      dotfiles="null"
      return
    fi
    echo -e "${NOTE}Hyprland with dotfiles will be installed.\n${WARNING}You did not select to install Hyprland, however you have selected to install dotfiles, so Hyprland will be installed anyway.${RESET}\n"
  elif [[ $installOptions == *"dotfiles"* ]]; then
    echo -e "${NOTE}Hyprland with dotfiles will be installed.\n"
  else
    echo -e "${NOTE}Hyprland will be installed.\n ${IMPORTANT}Note: This installs the bare minimum to run Hyprland. If you want to use it, you will need to install additional packages and configure it. Kitty will still be installed.${RESET}\n"
  fi
}
hyprland

if [[ ! $installoptions == *"lazyvim"* ]]; then
  lazyvim=""
else
  echo -e "${NOTE}LazyVim will be installed.\n"
fi

$helper -Sy --noconfirm --needed $powerlevel10k $hyprland $lazyvim

if [[ ! $installoptions == *"lazyvim"* ]]; then
  echo -e "${NOTE}Installing LazyVim.\n"
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  if [[ ! $? = 1 ]]; then
    echo -e "${ERROR}Failed to install LazyVim, config files may exist."
    lazyvimfail=true
  fi
fi

if [ lazyvimfail ]; then
  read -p "${NOTE}LazyVim failed to install. Do you want to move the configs from ${CYAN}~/.config/nvim${RESET} to ${CYAN}~/.config/nvim.bak${RESET} and start clean? (Y/n)" lazy
  if [[ ! lazy = [Nn] ]]; then #incorrect if statement
    echo 'mv ~/.config/nvim ~/.config/nvim.bak'
    mv ~/.config/nvim ~/.config/nvim.bak
  fi
fi
