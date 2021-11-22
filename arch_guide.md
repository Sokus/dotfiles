# Arch + i3-gaps

- [Clean installation](#clean-installation)
  - [Initial setup](#initial-setup)
    - [Disk formatting and partitioning](#disk-formatting-and-partitioning)
    - [GRUB](#grub)
    - [Networking](#networking)
      - [Wired](#wired)
      - [Wireless](#wireless)
    - [Common](#common)
- [Graphic Environment](#graphic-environment)
  - [Apps](#apps)
  - [Configuration](#configuration)
    - [Themes](#themes)
    - [Synchronize config files](#synchronize-config-files)
  - [Other](#other)
    
# Clean installation
## Initial setup
### Disk formatting and partitioning
fdisk operations:  
`l` - list devices  
`d` - delete existing partitions  
`n` - create partition (+512M)  
`t` - type: EFI System/EFI (Fat-12/16..)  
`n` - create (remaining disk size)  
(NOTE: you are on UEFI if `/sys/firmware/efi/efivars` exists)
```sh
fdisk /dev/sdX
mkfs.ext4 /dev/sdX2
mkfs.fat -F 32 /dev/sdX1
mount /dev/sdX2 /mnt
```

Install base packages
```sh
pacstrap /mnt base linux linux-firmware vim nano
```

```sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
passwd
```
### GRUB
```sh
pacman -S grub efibootmgr
mkdir /boot/efi
mount /dev/sdX1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
```

## Networking
```sh
echo [hostname] > /etc/hostname
touch /etc/hosts
```
Add to `/etc/hosts`:
```sh
127.0.0.1    localhost
::1          localhost
127.0.1.1    [hostname]
```
```sh
pacman -S dhcpcd
systemctl enable dhcpcd
```
#### Wired
Add to `/etc/dhcpcd.conf`:
```sh
interface enp3s0
static ip_address=192.168.x.x/24
static routers=192.168.1.1
static domain_name_servers=8.8.8.8
```
#### Wireless
TODO

## Common
```sh
pacman -S base-devel git
```
Add a user:
```sh
pacman -S sudo
useradd -m -G wheel -s /usr/bin/zsh [username]
passwd [username]
visudo
# uncomment %wheel ALL=(ALL) ALL
```
Install Paru:
```sh
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -sir
cd .. & rm -r paru
```
Timezone:
```sh
timedatectl set-timezone Europe/Warsaw
```
Locale:  
Uncomment `en_US.UTF-8` in `/etc/locale.gen`.
```sh
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
localectl set-keymap us
```

## Graphic environment
```sh
pacman -S i3 xorg xorg-xinit
pacman -S nvidia nvidia-utils nvidia-settings
pacman -S alsa-lib alsa-plugins pipewire pipewire-alsa pipewire-pulse pavucontrol
pacman -S ttf-dejavu ttf-inconsolata ttf-freefont ttf-libration ttf-droid ttf-roboto ttf-font-awesome noto-fonts
```
Add to `~/.xinitrc`:
```sh
#!/bin/bash
exec i3
```
Add to `/etc/profile`
```sh
if [[ "$(tty)" == '/dev/tty1' ]]; then
	exec startx
fi
```

### Apps:  
`picom`     - compositor  
`dmenu`     - application launcher  
`alacritty` - terminal emulator  
`ranger`    - CLI file explorer  
`xlip`      - clipboard  
`maim`      - screenshots  

### Configuration
#### Themes
```sh
mkdir -p ~/git/themes & cd ~/git/themes
```
Clone from `gh:dracula`: `alacritty` `ranger` `vim` `xresources` `zsh`  
Additional setup:
```sh
ln -s -T ~/git/themes/ranger/dracula.py ~/.config/ranger/colorschemes/dracula.py
ln -S -T ~/git/themes/xresources/Xresources ~/.Xresources
```
Add `RANGER_LOAD_DEFAULT_RC=FALSE` to `~/.xinitrc`.
#### Synchronize config files


### Other
Change X11 keyboard layout:  
Add `setxkbmap -layout pl` to `~/.xinitrc`
