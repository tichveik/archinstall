#!/usr/bin/env bash

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
            ruby perl transmission-gtk virtualbox zip unzip unrar \
            atom filezilla sudo git
}
