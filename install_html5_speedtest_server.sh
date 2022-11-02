#!/bin/bash

#
# app:       install apache2 php seld hosted lidrespeed html5 bandwidth speedtest
# author:    jamie whittingham
# created:   24.10.2022
# 
# (c) copyright by /dev/null.
#

# root user sanity check
(( UID != 0 )) && { echo "Error: you MUST be logged in as root."; exit 1; }

# change working dir
cd /root

# clear the terminal screen
clear

# banner
echo "============================================================"
echo "= title :    Install Apache2 PHP + HTML5 Speedtest         ="
echo "= author:    jamie whittingham                             ="
echo "= created:   24.10.2022                                    ="
echo "=                                                          ="
echo "============================================================"

# set vars
IPADDRESS=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# update apt
sudo apt update

# install packages
sudo apt install -y iftop htop nmap nload net-tools git apache2 php

# download repo
sudo git clone https://github.com/librespeed/speedtest.git /opt/speedtest

# change working dir
cd /opt/speedtest

# copy files to /var/www/html
sudo cp -R backend/ results/ *.js example-singleServer-full.html /var/www/html

# change working dir
cd /var/www/html

# move example config file to index.html
mv example-singleServer-full.html index.html

# enable auto test upon page load
sudo sed -i 's/<body/<body onload="startStop()"/' /var/www/html/index.html

# set ownership / permissions
sudo chown -R www-data *

# end
echo " "
echo "Server: http://"$IPADDRESS
echo " "