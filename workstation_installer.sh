#!/bin/bash
set -e
source fedorafunctions.sh
check_root
default_user=$(logname 2>/dev/null || echo ${SUDO_USER:-${USER}})
HOME="/home/${default_user}"
#-----------First part-----------------
UNINSTALL_WILD
ADD_FASTESTMIRROR
ENABLE_3RDPARTY_REPOS
SET_ALIASES
ENABLE_FLATHUB
INSTALL_FONTS
#INSTALL_STARSHIP
INSTALL_PFETCH
INSTALL_SYNTHSHELL
INSTALL_ST4
INSTALL_CODIUM
SETUP_GIT_REPOS
#----------Second part-------------------------
#-------------Flatpaks and Software-----------#
INSTALL_NEOVIM
INSTALL_TMUX
#--------------------
INSTALL_BLEACHBIT
INSTALL_VARIETY
INSTALL_QBITTORRENT
INSTALL_VLC
INSTALL_CALIBRE
#-------------------------
INSTALL_LIBREWOLF_FLATPAK
INSTALL_BRAVEBROWSER_FLATPAK
INSTALL_GOOGLECHROME_FLATPAK
#INSTALL_CHROMIUM_FLATPAK
INSTALL_FOLIATE_FLATPAK
INSTALL_KEEPASSXC_FLATPAK
INSTALL_BITWARDEN_FLATPAK
INSTALL_TORBROWSER_FLATPAK
INSTALL_SIGNAL_FLATPAK
INSTALL_TELEGRAM_FLATPAK
INSTALL_JOPLIN_FLATPAK
INSTALL_SHORTWAVE_FLATPAK
INSTALL_OKULAR_FLATPAK
UPDATE_AND_REBOOT
