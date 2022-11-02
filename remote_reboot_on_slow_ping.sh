#!/bin/bash

#
# app:       script to remotely reboot remote target that has a ping time higher than 100ms - designed for personal use as my nas has a hardware glitch
# author:    delta1372
# created:   11.09.2022
# 
# (c) copyright by /dev/null.
#

# ping time threshold
PING_TRIGGER='1000'

# target host
TARGET='192.168.200.210'

# ssh details
SSH_PORT='33077'
SSH_USERNAME='remote_reboot'
SSH_PASSWORD='ENTER_PASSWORD'

# remote command to execute
REMOTE_COMMAND='echo ENTER_PASSWORD | sudo -S reboot; logout;'

# ping the host
PING_TIME=$(ping -c 1 $TARGET | awk 'NR==2' | awk '{print $7}' | sed 's:\.[^|]*::g')

# we only want the time itself
PING_TIME=${PING_TIME:5}

# console output
echo '========================='
echo '===== REMOTE REBOOT ====='
echo '========================='
echo ' '
echo 'Target:           '$TARGET
echo 'Ping Trigger:     '$PING_TRIGGER ms
echo 'Ping Time:        '$PING_TIME ms
echo 'SSH Port:         '$SSH_PORT
echo 'SSH Username:     '$SSH_USERNAME
echo 'SSH Password:     '$SSH_PASSWORD
echo 'Remote Command:   '$REMOTE_COMMAND
echo ' '
echo 'SSH Command: 'sshpass -p \'$SSH_PASSWORD\' ssh -o StrictHostKeyChecking=no $SSH_USERNAME@$TARGET -p $SSH_PORT \"$REMOTE_COMMAND\"

# if ping time is higher than 100 then do something
if (( $PING_TIME > $PING_TRIGGER )); then
	# actions to take
	echo 'Running remote command.'
	# sshpass -p \'$SSH_PASSWORD\' ssh -o StrictHostKeyChecking=no $SSH_USERNAME@$TARGET -p $SSH_PORT \"$REMOTE_COMMAND\"
else
	# nothing to do
    echo 'Everything looks fine.'
fi