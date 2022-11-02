#!/bin/bash

#
# app:       install netbox
# author:    jamie whittingham
# created:   18.10.2022
# 
# (c) copyright by /dev/null.
#

# root user sanity check
(( UID != 0 )) && { echo "Error: you MUST be logged in as root."; exit 1; }

# clear the terminal screen
clear

# banner
echo "============================================================"
echo "= title :    NETBOX Installation Script                    ="
echo "= author:    jamie whittingham                             ="
echo "= created:   18.10.2022                                    ="
echo "=                                                          ="
echo "============================================================"

# install net-tools
sudo apt install -qq -y net-tools

# set vars
IPADDRESS=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
RANDOM_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 50 ; echo '' | xargs)

# update apt
sudo apt update

# upgrade system
sudo apt upgrade -y

# install postgressql
sudo apt install -y -qq postgresql

# enable and start postgresql
sudo systemctl start postgresql
sudo systemctl enable postgresql

# create database
sudo -u postgres psql -c "CREATE DATABASE netbox;"

# create database user and set password
sudo -u postgres psql -c "CREATE USER netbox WITH PASSWORD 'gjurtfjfh938737GRDV455';"

# set permissions for user and database
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;"

# install redis server
sudo apt install -y redis-server

# install dependencies
sudo apt install -y -qq git unzip python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev

# clone the netbox repo
sudo mkdir -p /opt/netbox
sudo git clone -b master --depth 1 https://github.com/netbox-community/netbox.git /opt/netbox

# create netbox system user
sudo adduser --system --group netbox
sudo chown --recursive netbox /opt/netbox/netbox/media/

# netbox configuration
cd /opt/netbox/netbox/netbox/
sudo cp configuration_example.py configuration.py

# update configuration.py file
sed -i 's/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \["*"\]/' /opt/netbox/netbox/netbox/configuration.py
sed -i "s/'USER': ''/'USER': 'netbox'/" /opt/netbox/netbox/netbox/configuration.py
sed -i "0,/PASSWORD/ s/'PASSWORD': ''/'PASSWORD': 'gjurtfjfh938737GRDV455'/" /opt/netbox/netbox/netbox/configuration.py

sed -i "s/SECRET_KEY = ''/SECRET_KEY = '"$RANDOM_KEY"'/" /opt/netbox/netbox/netbox/configuration.py

# update default admin account
sed -i "s/# ('John Doe', 'jdoe@example.com'),/('Jamie Whittingham', 'jamie@pidoxa.com'),/" /opt/netbox/netbox/netbox/configuration.py

# add NAPALM to local_requirements.txt so we can fetch live data from devices
sudo sh -c "echo 'napalm' >> /opt/netbox/local_requirements.txt"

# run the actual installer now we have made the needed modifications
sudo /opt/netbox/upgrade.sh

