#!/bin/bash
#
# Description: Bash script to connect automatically to the netsoul server
# This script implies using a modified ns_auth
#
# Written By: Alpha14 (contact@alpha14.com)
# Version: 1 (1-2014)

function ping_ns {
    if ping -q -c1 10.42.6.6 &> /dev/null
    then
	if ping -q -c1 8.8.8.8 &> /dev/null
	then
	    ping_network
	else
	    ns_connect
	fi
    else
	echo "`date` : failed to contact netsoul gatway"
	sleep 1
	ping_ns
    fi
}

function ns_connect {
    echo "`date` : executing ns_auth"
    ns_auth
    sleep 2
    ping_network
}

function ping_network {
    if ping -q -c1 8.8.8.8 &> /dev/null
    then
        echo "`date` : network up"
	sleep 5
	ping_network
    else
        echo "`date` : failed to contact network"
	ping_ns
    fi
}

ping_ns
