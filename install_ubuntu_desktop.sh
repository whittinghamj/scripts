#!/bin/bash

#
# app:       install ubuntu gui
# author:    delta1372
# created:   11.09.2022
# 
# (c) copyright by /dev/null.
#

sudo apt update
sudo apt upgrade -y
sudo apt install -y apt-transport-https htop nload iftop whois dnsutils sshpass ubuntu-desktop ubuntu-gnome-desktop xrdp

echo "GUI & RDP Installed."
