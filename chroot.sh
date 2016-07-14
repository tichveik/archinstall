#!/usr/bin/env bash

GREEN='\e[1;32m'        # Green
BLUE='\e[0;34m'         # Blue
CYAN='\e[0;36m'         # Cyan
WHITE='\e[0;37m'        # White
END='\e[0m'

LANG=fr_FR.UTF-8
export LANG=fr_FR.UTF-8
read -p 'Hostname: ' HOSTNAME
echo -e "Hostname: $HOSTNAME"

pacman-db-upgrade
pacman -S vim
echo $HOSTNAME >> /etc/hostname
ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo LANG=fr_FR.UTF-8 > /etc/locale.conf
export LANG=fr_FR.UTF-8
echo KEYMAP=fr >> /etc/vconsole.conf
