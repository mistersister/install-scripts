#!/bin/bash

# This script aims install apps and restore all the saved configurtions
# for apps, dotfiles, system files etc.

# 1. identify folders
backupFolder="/mnt/datos/backup/arch";
homeFolder="/home/cbarrabes";


# 2. perform postinstall (install apps, libraries etc)

# GPU drivers.
pacman -S --noconfirm nvidia nvidia-settings
# Specific KDE apps.
pacman -S --noconfirm kate ark okular filelight spectacle ksysguard plasma-systemmonitor powerdevil kcalc kinfocenter partitionmanager kwalletmanager sddm-kcm khotkeys plasma-pa
# KDE/Qt/Other libraries and modules.
pacman -S --noconfirm kde-gtk-config breeze-gtk qtcurve-qt5 qt5-gsettings gnome-keyring libgnome-keyring
# General applicationes I use.
pacman -S --noconfirm keepassxc libreoffice-fresh tilix evolution pavucontrol-qt firefox vlc audacity cherrytree qbittorrent oxygen gimp krita
# Dev stuff.
pacman -S --noconfirm jdk11-openjdk jdk8-openjdk maven git rpm-tools npm docker base-devel
# CLI utilites.
pacman -S --noconfirm openvpn rsync fping mlocate ntfs-3g dosfstools zip unzip unrar p7zip net-tools rofi cronie ntp cpio openssh tree jq vim
# Some fonts and eyecandy.
pacman -S --noconfirm otf-fira-mono otf-fira-sans ttf-fira-code ttf-fira-mono ttf-fira-sans woff-fira-code woff2-fira-code ttf-liberation noto-fonts-emoji
# Enable some basic services.
systemctl enable cronie
systemctl enable ntpd
systemctl enable sshd
# Remove GTK pavucontrol.
pacman -Rns --noconfirm pavucontrol

# 3. restore the app conifgs
# First the apps that go straight to .config
rsync -qa $backupFolder/apps/{cherrytree,deadbeef,freac,qBittorrent} $home/.config/
rsync -qa $backupFolder/desktops/plasma/dotfiles/* $home/.config/

# Now import tilix config
dconf load /com/gexperts/Tilix/ < $backupFolder/apps/tilix.dconf

# 4. Now restore the sysfiles (cron, keys, repos, etc)
rsync -qa $backupFolder/sysfiles/.bashrc $home/
tar -xvf $backupFolder/sysfiles/ssh_keys.tgz -C /home/cbarrabes/
rsync -qa $backupFolder/sysfiles/pacman.conf /etc/

# 5 Install vpn keys
rsync -qa $backupFolder/net/cbarrabes2fa/* /etc/openvpn/client/

# 6. Reload cron
crontab $backupFolder/sysfiles/cron.dat

# 7. Randoms
rsync -qa $backupFolder/desktops/menu_items/* $home/.local/share/applications
tar -xvf $backupFolder/apps/puddletag.tgz -C /home/cbarrabes/

# 8. Edits to hosts
echo 'mothership    172.20.0.81' >> /etc/hosts
echo 'battlestation    172.20.0.18' >> /etc/hosts

# set ntp
timedatectl set-ntp on

# set cassandra cqlsh
ln -s /mnt/datos/portables/cassandra-4.0.1/bin/cqlsh.py /usr/bin/cqlsh

# install yay-bin
cd /opt
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
su cbarrabes makepkg -si
cd ..
rm -f yay-bin
