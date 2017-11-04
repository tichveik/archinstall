#!/usr/bin/env bash

GREEN='\e[1;32m'        # Green
BLUE='\e[0;34m'         # Blue
CYAN='\e[0;36m'         # Cyan
WHITE='\e[0;37m'        # White
END='\e[0m'

export LC_ALL=""
export LC_COLLATE=C

LANG=fr_FR.UTF-8
export LANG=fr_FR.UTF-8
read -p 'Hostname: ' HOSTNAME
echo -e "Hostname: $HOSTNAME"

modprobe dm-mod
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
sed -i '7s/""/"sd-mod" /' /etc/mkinitcpio.conf
sed -i '52s/\(block \)/\1 keymap encrypt lvm2 resume /' /etc/mkinitcpio.conf
echo -e $GREEN":: Création de la ramdisk"$END
mkinitcpio -p linux
echo -e $GREEN":: Installation de GRUB"$END
pacman -S grub-bios os-prober
grub-install --boot-directory=/boot --no-floppy --recheck /dev/sda
cp /usr/share/grub/{unicode.pf2,ascii.pf2} /boot/grub
echo -e $GREEN":: Configuration de grub"$END
sed -i '6s/"quiet"/"verbose" /' /etc/default/grub
sed -i '7s/""/"cryptdevice\=\/dev\/sda2\:sda2_crypt resume\=\/dev\/mapper\/CryptGroup\-lvswap pcie\_aspm\=force elevator\=noop" /' /etc/default/grub
echo -e $GREEN"Géneration de grub.cfg"$END
grub-mkconfig -o /boot/grub/grub.cfg
echo -e $GREEN"Mot de passe pour root:"$END
passwd root
echo -e $GREEN"Ajout d'un utilisateur"
read -p 'Utilisateur: ' USER1
useradd -g users -m $USER1
passwd $USER1

post(){
  read -p 'Voulez vous installer Xorg ? (Y/N): ' REP
  if [ $REP = Y ]; then
    pacman -S xorg
  fi
  read -p 'Voulez vous installer un gestionair de connexion (Y/N): ' REP
  if [ $REP = Y ]; then
    echo "1) gdm"
    echo "2) lightdm"
    echo "3) sddm"
    read -p 'Votre choix: ' REP
    case $REP in
      1) pacman -S gdm ;;
      2) pacman -S lightmd ;;
      3) pacman -S sddm ;;
    esac
  fi
  read -p "Voulez vous installer un environnement graphique (Y/N)" REP
    if [ $REP = Y ]; then
      echo "1) gnome"
      echo "2) KDE"
      echo "3) XFCE"
      read -p "Choix de l'environnement graphique: " REP
      case $REP in
        1) pacman -S gnome;;
        2) pacman -S plasma-desktop ;;
        3) pacman -S xfce ;;
      esac
    fi
  echo ":: Installation des utilitaires usuels"
  pacman -S firefox firefox-i18n-fr libreoffice-still vlc zsh \
            ruby perl transmission-gtk virtualbox zip unzip rar 7zip \
            atom filezilla
}
