#!/bin/bash

#
# app:       install docker and portainer script
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
echo "= title :    Docker + Portainer Installation Script        ="
echo "= author:    jamie whittingham                             ="
echo "= created:   01.10.2022                                    ="
echo "=                                                          ="
echo "============================================================"

# set vars
IPADDRESS=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# upgrade apt repo
apt update -qqq

# upgrade everything thats already installed on the systerm
apt upgrade -y -qqq

# remove anything that we no longer need
apt autoremove -y -qqq

# install a few prerequisite packages which let apt use packages over HTTPS
apt install -y -qqq apt-transport-https ca-certificates curl software-properties-common

# add the GPG key for the official Docker repository to your system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# add docker repo to apt
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# update apt package list to see new docker repo
apt update -qqq

# make sure you are about to install from the Docker repo instead of the default repo
apt-cache policy docker-ce

# install docker
apt install -y -qqq docker-ce

# check if docker is installed and running
# systemctl status docker

# create persistant storage for portainer
docker volume create portainer_data

# download and installportainer server
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:2.11.1

# footer
echo " "
echo " "
echo " "
echo "=================================================="
echo " Installation Complete"
echo " Portainer URL: https://$IPADDRESS:9443"
echo "=================================================="
