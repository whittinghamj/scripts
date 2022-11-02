#!/bin/bash

#
# app:       install nginx and torrc server to host .onion hidden website content
# author:    delta1372
# created:   11.09.2022
# 
# (c) copyright by /dev/null.
#

# update apt
sudo apt update

# install nginx and tor
sudo apt install -y tor nginx

# enable tor server
sed -i 's/#HiddenServiceDir/HiddenServiceDir/' /etc/tor/torrc
sed -i 's/#HiddenServicePort/HiddenServicePort/' /etc/tor/torrc

# restart tor service
sudo systemctl restart tor.service

# make a default index.html file
echo 'Welcome to our Tor website' > /var/www/html/index.html

# get the tor website address
TORADDRESS="$(cat /var/lib/tor/hidden_service/hostname)";

# get ipv4 address
IPADDRESS="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')";

# clear the screen
clear

# echo some results
echo "HTML Root: /var/www/html";
echo "IPv4 / Insecure URL: http://$IPADDRESS";
echo "Tor / Secure URL http://$TORADDRESS";
echo " ";
