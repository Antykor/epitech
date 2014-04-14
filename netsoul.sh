#!/bin/bash
#
# Description: Bash script to connect automatically to the netsoul server
# This script implies using a modified ns_auth
#
# Written By: Alpha14 (contact@alpha14.com)
# Version: 2 (4-2014)

REMOTE_IP="8.8.4.4"
GATEWAY=$(route -n|grep "UG"|grep -v "UGH"|cut -f 10 -d " ")

function ping_ns {
    if ping -q -w 1 -c1 ${GATEWAY} &> /dev/null
    then
	if ping -q -w 1 -c1 ${REMOTE_IP} &> /dev/null
	then
	    ping_network
	else
	    ns_connect
	fi
    else
	echo "`date` : failed to contact gateway"
	sleep 1
	ping_ns
    fi
}

function ns_connect {
    echo "`date` : executing ns_auth"
    ns_auth
    sleep 1
    ping_network
}

function ping_network {
    if ping -q -w 1 -c1 ${REMOTE_IP} &> /dev/null
    then
        echo "`date` : network up"
	sleep 4
	ping_network
    else
        echo "`date` : failed to contact network"
	ping_ns
    fi
}

ping_ns
