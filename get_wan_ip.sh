#!/bin/bash

#
# app:       get public wan IP
# author:    delta1372
# created:   11.09.2022
# 
# (c) copyright by /dev/null.
#

# dig command
WAN_IP=$(dig @resolver4.opendns.com myip.opendns.com +short)

# console output
echo 'Public IP: '$WAN_IP

