#!/bin/bash

###########################################################################
# https://forum.manjaro.org/t/howto-install-manjaro-using-cli-only/108203
# https://linux-aarhus.dk/wp-content/uploads/manjaro/Manjaro_CLI_installation.pdf
###########################################################################
set -e

source .envrc
loadkeys us

pacman-mirrors --api --set-branch stable --url https://manjaro.moson.org

# enable this when connections are bad or packages are out of date
# pacman-mirrors -f

pacman --noconfirm -Syy pacman archlinux-keyring manjaro-keyring

pacman-key --init
pacman-key --populate archlinux manjaro
pacman-key --refresh-keys --keyserver hkp://pool.sks-keyservers.net

# https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/security/t_security_settingupluksencryption.html
echo -e "$ROOT_PARTITION_PASSWORD" | cryptsetup -q luksFormat $ROOT_PARTITION
echo "$ROOT_PARTITION_PASSWORD" | cryptsetup luksOpen $ROOT_PARTITION cryptroot

# format our partitions
mkfs.fat -F 32 $EFI_PARTITION
mkfs.ext4 -F $BOOT_PARTITION
mkfs.ext4 -F /dev/mapper/cryptroot
mkswap $SWAP_PARTITION


mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot/efi
mount $BOOT_PARTITION /mnt/boot/
mkdir -p /mnt/boot/efi
mount $EFI_PARTITION /mnt/boot/efi

basestrap /mnt $LINUX_KERNEL \
  base-devel \
  yay \
  acpi \
  amd-ucode \
  b43-fwcutter \
  bash \
  btrfs-progs \
  bzip2 \
  coreutils \
  crda \
  dhclient \
  diffutils \
  dmraid \
  dnsmasq \
  dosfstools \
  e2fsprogs \
  ecryptfs-utils \
  efibootmgr \
  exfat-utils \
  f2fs-tools \
  filesystem \
  findutils \
  gawk \
  gcc-libs \
  gettext \
  glibc \
  grep \
  gzip \
  inetutils \
  intel-ucode \
  iproute2 \
  iptables \
  iputils \
  ipw2100-fw \
  ipw2200-fw \
  jfsutils \
  less \
  licenses \
  linux-firmware \
  logrotate \
  lsb-release \
  man-db \
  manjaro-firmware \
  manjaro-release \
  manjaro-system \
  man-pages \
  memtest86+ \
  mhwd \
  mhwd-db \
  mkinitcpio-openswap \
  nano \
  ntfs-3g \
  os-prober \
  pacman \
  pciutils \
  perl \
  procps-ng \
  psmisc \
  sed \
  shadow \
  spectre-meltdown-checker \
  s-nail \
  sudo \
  sysfsutils \
  acpid \
  cpupower \
  cronie \
  cryptsetup \
  device-mapper \
  dhcpcd \
  haveged \
  lvm2 \
  mdadm \
  nfs-utils \
  rsync \
  systemd-fsck-silent
  # systemd-sysvcompat \
  # tlp \
  # wpa_supplicant \
  # tar \
  # texinfo \
  # usbutils \
  # util-linux \
  # wget \
  # which \
  # xfsprogs \
  # zsh \
  # avahi \
  # networkmanager \
  # networkmanager-openconnect \
  # networkmanager-openvpn \
  # networkmanager-pptp \
  # networkmanager-vpnc \
  # nss-mdns \
  # ntp \
  # mobile-broadband-provider-info \
  # modemmanager \
  # openresolv \
  # openssh \
  # samba \
  # usb_modeswitch \
  # alsa-firmware \
  # alsa-utils \
  # ffmpeg \
  # gst-libav \
  # gst-plugins-base \
  # gst-plugins-good \
  # gst-plugins-ugly \
  # libdvdcss \
  # manjaro-pulse \
  # pulseaudio-bluetooth \
  # pulseaudio-ctl \
  # pulseaudio-zeroconf \
  # android-tools \
  # android-udev \
  # gvfs \
  # gvfs-afc \
  # gvfs-gphoto2 \
  # gvfs-mtp \
  # gvfs-nfs \
  # gvfs-smb \
  # mtpfs \
  # udiskie \
  # udisks2 \
  # cantarell-fonts \
  # noto-fonts \
  # terminus-font \
  # ttf-bitstream-vera \
  # pamac \
  # accountsservice \
  # exo \
  # garcon \
  # thunar \
  # thunar-volman \
  # tumbler \
  # xfce4-appfinder \
  # xfce4-panel \
  # xfce4-power-manager \
  # xfce4-session \
  # xfce4-settings \
  # xfconf \
  # xfdesktop \
  # xfwm4 \
  # blueman \
  # ffmpegthumbnailer \
  # freetype2 \
  # gnome-keyring \
  # libopenraw \
  # light-locker \
  # network-manager-applet \
  # refind \
  # refind-theme-maia \
  # mkinitcpio \
  # efibootmgr \
  # vim \
  # links

manjaro-chroot /mnt /bin/bash

# https://wiki.manjaro.org/Configure_Graphics_Cards
sudo mhwd -a pci nonfree 0300

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
useradd $USER_NAME sys network,power,video,storage,lp,input,audio,wheel
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USER_NAME

mkinitcpio -p $LINUX_KERNEL

genfstab -U /mnt >> /mnt/etc/fstab

refind-install

# install refind

exit
umount -R /mnt
reboot
