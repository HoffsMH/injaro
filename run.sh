#!/bin/bash

###########################################################################
# https://forum.manjaro.org/t/howto-install-manjaro-using-cli-only/108203
###########################################################################

loadkeys us
systemctl enable --now systemd-timesyncd

pacman-mirrors --api --set-branch stable --url https://manjaro.moson.org
pacman -Syy pacman archlinux-keyring manjaro-keyring

pacman-key --init
pacman-key --populate archlinux manjaro
pacman-key --refresh-keys
