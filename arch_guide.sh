#!/bin/bash
echo "Not intended for execution!" 1>&2; exit 1;


# if /sys/firmware/efi/efivars directory"
# exists you are on UEFI system

# Disk formatting and partitioning
fdisk -l
fdisk /dev/???
fdisk -d # delete existing partitions
fdisk -n # primary, +512M
fdisk -t # type: EFI System/EFI (Fat-12/16..)
fdisk -n # primary, remaining disk size
mkfs.ext4 /dev/root_partition
mkfs.fat -F 32 /dev/efi_system_partition
mount /dev/root_partition /mnt

# Update mirrorlist for faster system download
pacman -Syy
pacman -S reflector
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "PL" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

# Install Arch
pacstrap /mnt base linux linux-firmware vim nano

# System config
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
timedatectl set-timezone Europe/Warsaw
vim /etc/locale.gen # uncomment en_US.UTF-8
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo [hostname] > /etc/hostname
touch /etc/hosts
vim /etc/hosts
# 127.0.0.1		localhost
# ::1			localhost
# 127.0.1.1		[hostname]
systemctl enable dhcpcd
passwd

# GRUB setup
pacman -S grub efibootmgr
mkdir /boot/efi
mount /dev/efi_system_partition /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

# DE installation, example:
pacman -S xorg gnome
systemctl start gdm.service
systemctl enable gdm.service
systemctl enable NetworkManager.service # IMPORTANT!

# Add new user with root privileges
adduser [username]
passwd [username]
usermod -aG wheel [username]
vim /etc/sudoers # uncomment %wheel ALL=(ALL) ALL