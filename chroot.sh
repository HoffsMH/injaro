#! /bin/bash

source .envrc

# https://wiki.manjaro.org/Configure_Graphics_Cards
mhwd -a pci nonfree 0300

echo -e "
KEYMAP=us
FONT=ter-116n" > /etc/vconsole.conf

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US ISO-8859-1" >> /etc/locale.gen
locale-gen

ntpd -qg
timedatectl set-timezone "$(curl --fail https://ipapi.co/timezone)"
hwclock -w

echo $MACHINE_NAME > /etc/hostname
systemctl enable dhcpcd
systemctl enable NetworkManager

# set root passwd
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd
useradd $USER_NAME -G sys,network,power,video,storage,lp,input,audio,wheel
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USER_NAME

mkinitcpio -p $LINUX_KERNEL

genfstab -U / >> /etc/fstab

# install refind
refind-install


