#!/bin/bash

#
# app:       install kasm
# author:    jamie whittingham
# created:   01.10.2022
# 
# (c) copyright by /dev/null.
#

# root user sanity check
(( UID != 0 )) && { echo "Error: you MUST be logged in as root."; exit 1; }

# clear the terminal screen
clear

# banner
echo "============================================================"
echo "= title :    Kasm Installation Script                      ="
echo "= author:    jamie whittingham                             ="
echo "= created:   01.10.2022                                    ="
echo "=                                                          ="
echo "============================================================"


# set vars
IPADDRESS=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# move into the /root folder
cd /root

# create a swap partition
sudo dd if=/dev/zero bs=1M count=1024 of=/mnt/1GiB.swap

# upgrade swap partition permissions
sudo chmod 600 /mnt/1GiB.swap

# make it into a swap partition
sudo mkswap /mnt/1GiB.swap

# turn on the new swap partition
sudo swapon /mnt/1GiB.swap

# add swap file to fstab so it survives reboot
echo '/mnt/1GiB.swap swap swap ddefaults 0 0' | sudo tee -a /etc/fstab

# download kasm
wget -qqq https://kasm-static-content.s3.amazonaws.com/kasm_release_1.11.0.18142e.tar.gz

# extract the compressed file
tar -xf kasm_release_1.11.0.18142e.tar.gz

# run the kasm installer
sudo bash kasm_release/install.sh --accept-eula --admin-password admin1372

# footer
echo " "
echo " "
echo " "
echo "=================================================="
echo " Installation Complete"
echo " Kasm URL: https://$IPADDRESS"
echo "=================================================="
