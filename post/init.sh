#!/bin/bash

source /post/config

## LOCALTIME 
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime &&
hwclock --systohc &&
timedatectl set-ntp true &&
timedatectl set-timezone Asia/Jakarta &&


## LOCALES
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen  
echo "en_US ISO-8859-1" >> /etc/locale.gen   
locale-gen &&


## DIRECTO
mkdir /opt/flat &&
ln -sf /opt/flat /var/lib/flatpak &&

## INSTALL
pacman -Syy --noconfirm &&
pacman -S linux-zen\
    scx-scheds \
    wireless-regdb \
    mkinitcpio \
    base-devel \
    mesa \
    konsole \
    linux-firmware \
    sof-firmware \
    openssh \
    firewalld \
    bluez-utils \
    dnsmasq \
    networkmanager \
    neovim \
    dolphin \
    jack2 \
    pipewire \
    wireplumber \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    ttf-droid \
    kitty-terminfo \
    bash-completion \
    git \
    wget \
    unzip \
    flatpak \
    discover \
    fuse \
    btop \
    sddm \
    sddm-kcm \
    firefox \
    kwallet \
    weston \
    plasma \
    kwalletmanager \
    aria2 \
    krita \
    blender \
    hiprt \
    inkscape \
    gimp \
    carla \
    tenacity \
    qtractor \
    hydrogen \
    yoshimi \
    digikam \
    sweethome3d \
    breeze-icons \
    darktable \
    scribus \
    keepassxc \
    waydroid  --noconfirm &&


if [[ ! -z $( lscpi | grep Intel ) ]]; then
    pacman -S intel-ucode 
fi

if [[ ! -z $( lscpi | grep NVIDIA ) ]]; then
    pacman -S cuda 
fi

if [[ ! -z $( lscpi | grep AMD ) ]]; then
    pacman -S hip-runtime-amd amd-ucode 
fi

## CONFIG
cp -fr /post/base/* / &&
cp -fr /post/extra/amd/* / &&


## LOCALE
locale-gen &&

##
## SERVICE
systemctl enable sddm &&
systemctl enable dnsmasq &&
systemctl enable update.timer &&
systemctl enable NetworkManager &&
systemctl enable --global pipewire-pulse &&
systemctl enable systemd-timesyncd.service &&
systemctl enable waydroid-container.service


##
## BOOTUPS
mkdir -p /boot/{efi,kernel,loader}
mkdir -p /boot/efi/{boot,linux,systemd,rescue}
mv /boot/vmlinuz-linux-zen /boot/*-ucode.img /boot/kernel/
rm /etc/mkinitcpio.conf
rm -fr /etc/mkinitcpio.conf.d/
rm /boot/initramfs-*
bootctl --path=/boot/ install


## EXECUTE
chmod +x /usr/xbin/* &&
chmod +x /usr/lbin/* &&
chmod +x /usr/rbin/* &&

## LUKSDISK
echo "rd.luks.name=$(blkid -s UUID -o value $DISKPROC)=root root=/dev/proc/root" > /etc/cmdline.d/01-boot.conf &&
echo "data UUID=$(blkid -s UUID -o value $DISKDATA) none" >> /etc/crypttab 
mkinitcpio -P


## ADMIN ADD
useradd -d /var/lib/telnet -u 23 net &&
usermod -aG wheel net &&
chown -R net:net /var/lib/telnet &&
passwd net

mkinitcpio -P

## NOTIF
echo "
1. create user before logout and add user as administrator
"
