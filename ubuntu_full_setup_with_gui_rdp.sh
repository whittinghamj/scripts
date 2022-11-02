#!/bin/bash

#
# app:       debian / ubuntu system setup with tools, gui and rdp
# author:    delta1372
# created:   11.09.2022
# 
# (c) copyright by /dev/null.
#

## set system limits
echo 'net.core.wmem_max= 1677721600' >> /etc/sysctl.conf
echo 'net.core.rmem_max= 1677721600' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem= 1024000 8738000 1677721600' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem= 1024000 8738000 1677721600' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_no_metrics_save = 1' >> /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 5000' >> /etc/sysctl.conf
echo 'net.ipv4.route.flush=1' >> /etc/sysctl.conf
echo 'fs.file-max=65536' >> /etc/sysctl.conf
sysctl -p

# disable old fd0
sudo rmmod floppy
echo "blacklist floppy" | sudo tee /etc/modprobe.d/blacklist-floppy.conf
sudo dpkg-reconfigure initramfs-tools

## update apt-get repos
apt update

## upgrade all packages
apt -y upgrade

## disable apparmor
service apparmor stop
update-rc.d -f apparmor remove 
apt remove -y apparmor apparmor-utils

## remove sendmail
service sendmail stop; update-rc.d -f sendmail remove

## install dependencies
apt install -y apt-transport-https ntp mariadb-client openssl rkhunter binutils bc nfs-common htop nload nmap sudo gcc make git autoconf autogen automake pkg-config locate curl dnsutils sshpass zip iftop hping3
updatedb >/dev/null 2>&1

## download custom scripts
rm -rf /root/.bashrc
wget -q http://genexnetworks.net/scripts/.bashrc >/dev/null 2>&1
rm -rf /etc/skel/.bashrc
cp /root/.bashrc /etc/skel
chmod 777 /etc/skel/.bashrc

## setup sudo account
useradd -m -p eioruvb9eu839ub3rv delta1372
echo "delta1372:"'admin1372' | chpasswd >/dev/null 2>&1
usermod -aG sudo delta1372
mkdir -p /home/delta1372/.ssh
wget -q -O /home/delta1372/.ssh/authorized_keys https://raw.githubusercontent.com/whittinghamj/scripts/main/whittinghamj_ssh_key.txt >/dev/null 2>&1
echo "delta1372    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

## change SSH port to 33077 and only listen to IPv4
echo "Updating SSHd details"
sed -i 's/#Port/Port/' /etc/ssh/sshd_config
sed -i 's/22/33077/' /etc/ssh/sshd_config
sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config
/etc/init.d/ssh restart >/dev/null 2>&1

## copy custom .bashrc to home dir
cp /root/.bashrc /home/delta1372

## install rdp
sudo apt install -y ubuntu-desktop ubuntu-gnome-desktop xrdp firefox

echo "Installation complete, you might want to reboot."
