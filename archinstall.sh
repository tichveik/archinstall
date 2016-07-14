#!/usr/bin/env bash

RED='\e[0;31m'          # Red
GREEN='\e[1;32m'        # Green
BLUE='\e[0;34m'         # Blue
CYAN='\e[0;36m'         # Cyan
WHITE='\e[0;37m'        # White
END='\e[0m'
LOG=installation.log
export LANG=fr_FR.UTF-8
LANG=fr_FR.UTF-8

echo ""
echo -e $CYAN":: Installation d'ArchLinux"$END
echo ""
sleep 3
touch $LOG 


parts(){
    #cfdisk /dev/sda
    echo -e $GREEN":: Création de la table de partition"$END
    parted -s /dev/sda mklabel msdos
    echo -e $GREEN":: Création de la partition boot"$END
    parted -s /dev/sda mkpart primary 1Mib 250Mib
    parted -s /dev/sda set 1 boot on
    echo -e $GREEN":: Création de la partition /"$END
    parted -s /dev/sda mkpart primary 250Mib 100%
    }

enc(){
    echo -e $GREEN":: Chiffrement du disque"$END
    cryptsetup -c aes-xts-plain -y -s 512 luksFormat /dev/sda2
    if [ $? = 0 ];then
        echo -e $GREEN":: Ouverture du disque"$END
        cryptsetup luksOpen /dev/sda2 sda2_crypt 
        modprobe dm-mod 
        echo -e $GREEN":: Création du volume physique"$END
        pvcreate /dev/mapper/sda2_crypt
        echo -e $GREEN":: Création du groupe de volume"$END
        vgcreate CryptGroup /dev/mapper/sda2_crypt
        echo -e $GREEN":: Création des volumes logiques (swap & /)"$END
        lvcreate -C y -L 4G CryptGroup -n lvswap
        lvcreate -l +100%FREE CryptGroup -n lvarch
        echo -e $GREEN":: Appliquation du systeme de fichier pour /boot"$END
        mkfs.ext4 -q /dev/sda1
        echo -e $GREEN":: Appliquation du systeme de fichier pour swap"$END
        mkswap  /dev/mapper/CryptGroup-lvswap -L swap
        echo -e $GREEN":: Appliquation du systeme de fichier pour /"$END
        mkfs.ext4 -q /dev/mapper/CryptGroup-lvarch -L arch
    else
        echo -e $RED":: Erreure de Chiffrement !"$END
        exit 
    fi
    }

hop(){
    echo -e $GREEN":: Montage de la partition racine sur /mnt$END"
    mount /dev/mapper/CryptGroup-lvarch /mnt
    echo -e $GREEN":: Activation du swap"$END
    swapon /dev/mapper/CryptGroup-lvswap
    echo -e $GREEN":: Création du repertoir /boot"$END
    mkdir /mnt/boot
    echo -e $GREEN":: Montage de la partition /boot"$END
    mount /dev/sda1 /mnt/boot
    echo -e $GREEN":: Installation du systeme de base"$END
    pacstrap /mnt base base-devel
    }

fchroot(){
    echo -e $GREEN":: Configuration de /etc/fstab"$END
    genfstab -U -p /mnt  >> /mnt/etc/fstab
    echo -e $GREEN":: Chroot..."$END
    echo -e $GREEN":: Copie du script chroot"$END
    cp -v chroot.sh /mnt/root/
    mount -o remount,exec /mnt
    arch-chroot /mnt/ /root/chroot.sh
}
parts
enc
hop
fchroot
