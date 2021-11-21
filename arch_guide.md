# check: if /sys/firmware/efi/efivars exists"

# Disk formatting and partitioning
fdisk -l
fdisk /dev/sdX
# d - delete existing partitions
# n - create partition (+512M)
# t - type: EFI System/EFI (Fat-12/16..)
# n - create (remaining disk size)
mkfs.ext4 /dev/sdX2
mkfs.fat -F 32 /dev/sdX1
mount /dev/sdX2 /mnt

# Install Arch
pacstrap /mnt base linux linux-firmware vim nano zsh

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
passwd

# DHCP
# Wired
pacman -S dhcpcd
interface enp3s0
static ip_address=192.168.x.x/24
static routers=192.168.1.1
static domain_name_servers=8.8.8.8
systemctl enable dhcpcd

# GRUB setup
pacman -S grub efibootmgr
mkdir /boot/efi
mount /dev/sdX1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

# New user with root privileges
pacman -S sudo
vim /etc/sudoers # uncomment %wheel ALL=(ALL) ALL
useradd -m -G wheel -s /usr/bin/zsh username
passwd username

# Common
pacman -S base-devel unzip htop git bat fd tree

# Paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -sir

# Graphic environment
pacman -S i3 xorg xorg-xinit picom
pacman -S nvidia nvidia-utils nvidia-settings
pacman -S alsa-lib alsa-plugins pipewire pipewire-alsa pipewire-pulse pavucontrol
pacman -S ttf-dejavu ttf-inconsolata ttf-freefont ttf-libration ttf-droid ttf-roboto ttf-font-awesome noto-fonts

# Apps 
# dmenu     - application launcher
# alacritty - terminal emulator
# ranger    - CLI file explorer
# xlip      - clipboard
# maim      - screenshots

vim ~/.xinitrc
# #!/bin/bash
# exec i3
vim /etc/profile
# if [[ "$(tty)" == '/dev/tty1' ]]; then
#     exec startx
# fi
cp /etc/i3status.conf ~/.config/i3status/config

# Keyboard layout
localectl set-keymap us
vim ~/.xinitrc
# setxkbmap -layout pl
