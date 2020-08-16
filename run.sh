#!/bin/bash

###########################################################################
# https://forum.manjaro.org/t/howto-install-manjaro-using-cli-only/108203
# https://linux-aarhus.dk/wp-content/uploads/manjaro/Manjaro_CLI_installation.pdf
###########################################################################
su
loadkeys us

pacman-mirrors --api --set-branch stable --url https://manjaro.moson.org
pacman -Syy pacman archlinux-keyring manjaro-keyring

pacman-key --init
pacman-key --populate archlinux manjaro
pacman-key --refresh-keys
