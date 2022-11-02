#!/bin/bash

#
# app:       system prep
# author:    jamie whittingham
# created:   02.11.2022
# 
# (c) copyright by /dev/null.
#

# root user sanity check
(( UID != 0 )) && { echo "Error: you MUST be logged in as root."; exit 1; }

## set base folder
cd /root >/dev/null 2>&1

# clear the terminal screen
clear

# banner
echo "============================================================"
echo "= title :    System Prep Script                            ="
echo "= author:    jamie whittingham                             ="
echo "= created:   02.11.2022                                    ="
echo "============================================================"

## set system limits
echo 'net.core.wmem_max= 1677721600' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.core.rmem_max= 1677721600' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.ipv4.tcp_rmem= 1024000 8738000 1677721600' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.ipv4.tcp_wmem= 1024000 8738000 1677721600' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.ipv4.tcp_no_metrics_save = 1' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.core.netdev_max_backlog = 5000' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'net.ipv4.route.flush=1' >> /etc/sysctl.conf >/dev/null 2>&1
echo 'fs.file-max=65536' >> /etc/sysctl.conf >/dev/null 2>&1
sysctl -p >/dev/null 2>&1

# disable old fd0
sudo rmmod floppy >/dev/null 2>&1
echo "blacklist floppy" | sudo tee /etc/modprobe.d/blacklist-floppy.conf >/dev/null 2>&1
sudo dpkg-reconfigure initramfs-tools >/dev/null 2>&1

## update apt repos
echo "Updating repos"
apt update >/dev/null 2>&1

## upgrade all packages
echo "Upgrading OS"
apt upgrade -qq -y >/dev/null 2>&1

## disable apparmor
service apparmor stop >/dev/null 2>&1
update-rc.d -f apparmor remove >/dev/null 2>&1
apt remove -qq -y apparmor apparmor-utils >/dev/null 2>&1

## sync system clock
apt -qq -y install ntp >/dev/null 2>&1

## remove sendmail
service sendmail stop; update-rc.d -f sendmail remove >/dev/null 2>&1

## install dependencies
echo "Installing core packages"
apt install -qq -y dialog net-tools mariadb-client openssl rkhunter binutils python bc nfs-common htop nload nmap sudo gcc make git autoconf autogen automake pkg-config locate curl dnsutils sshpass fping jq zip iftop  >/dev/null 2>&1
updatedb >/dev/null 2>&1

## download custom scripts
echo "Downloading custom scripts"
wget -q http://genexnetworks.net/scripts/speedtest.sh >/dev/null 2>&1
rm -rf /root/.bashrc >/dev/null 2>&1
wget -q http://genexnetworks.net/scripts/.bashrc >/dev/null 2>&1
rm -rf /etc/skel/.bashrc >/dev/null 2>&1
cp /root/.bashrc /etc/skel >/dev/null 2>&1
chmod 777 /etc/skel/.bashrc >/dev/null 2>&1

## setup whittinghamj account
if [ -z "$(getent passwd whittinghamj)" ]; then
	useradd -m -s /bin/bash whittinghamj >/dev/null 2>&1
	usermod -aG sudo whittinghamj >/dev/null 2>&1
	mkdir -p /home/whittinghamj/.ssh >/dev/null 2>&1
	wget -q -O /home/whittinghamj/.ssh/authorized_keys https://raw.githubusercontent.com/whittinghamj/scripts/main/whittinghamj_ssh_key.txt >/dev/null 2>&1
	echo "whittinghamj    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

## setup aegrant account
if [ -z "$(getent passwd aegrant)" ]; then
	useradd -m -s /bin/bash aegrant >/dev/null 2>&1
	usermod -aG sudo aegrant >/dev/null 2>&1
	mkdir /home/aegrant/.ssh >/dev/null 2>&1
	wget -q -O /home/aegrant/.ssh/authorized_keys https://raw.githubusercontent.com/whittinghamj/scripts/main/aegrant_ssh_key.txt >/dev/null 2>&1
	echo "aegrant    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

## setup cwiegand account
if [ -z "$(getent passwd cwiegand)" ]; then
	useradd -m -s /bin/bash cwiegand >/dev/null 2>&1
	usermod -aG sudo cwiegand >/dev/null 2>&1
	mkdir /home/cwiegand/.ssh >/dev/null 2>&1
	wget -q -O /home/cwiegand/.ssh/authorized_keys https://raw.githubusercontent.com/whittinghamj/scripts/main/cwiegand_ssh_key.txt >/dev/null 2>&1
	echo "cwiegand    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

## change SSH port to 33077 and only listen to IPv4
echo "Updating SSHd details"
sed -i 's/#Port/Port/' /etc/ssh/sshd_config >/dev/null 2>&1
sed -i 's/22/33077/' /etc/ssh/sshd_config >/dev/null 2>&1
sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config >/dev/null 2>&1
/etc/init.d/ssh restart >/dev/null 2>&1

# reboot options
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="System Installer"
TITLE="Reboot Options"
MENU="Do you want to reboot?"

OPTIONS=(1 "Yes, reboot now."
         2 "No, exit script.")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            sudo reboot
            ;;
        2)
            echo "Installation Complete"
            ;;
esac

