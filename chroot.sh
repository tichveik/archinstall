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
echo $HOSTNAME >> /etc/hostname
ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
echo -e $GREEN":: Configuration des locales"$END
echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo LANG=fr_FR.UTF-8 > /etc/locale.conf
export LANG=fr_FR.UTF-8
echo KEYMAP=fr >> /etc/vconsole.conf
echo -e $GREEN":: Configuration du fichier mkinitcpio.conf"$END
sed -i '7s/""/ sd-mod /' /etc/mkinitcpio.conf
sed -i '52s/ / keymap encrypt lvm2 resume /' /etc/mkinitcpio.conf
echo -e $GREEN":: Création de la ramdisk"$END
mkinitcpio -p linux
echo -e $GREEN":: Installation de GRUB"$END
pacman -S grub-bios os-prober
grub-install --boot-directory=/boot --no-floppy --recheck /dev/sda
cp /usr/share/grub/{unicode.pf2,ascii.pf2} /boot/grub
