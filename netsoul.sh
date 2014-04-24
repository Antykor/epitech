#!/bin/bash
#
# Description: Bash script to connect automatically to the netsoul server
# This script implies using a modified ns_auth
#
# Written By: Alpha14 (contact@alpha14.com)
# Version: 3 (4-2014)

REMOTE_IP="8.8.4.4"
WLANSTATE=$(iwconfig wlan0 | grep "Access Point" | cut -d: -f4)
MSG=0

function network_wait
{
    GATEWAY=$(route -n|grep "UG"|grep -v "UGH"|cut -f 10 -d " ")
    if [ -z "$GATEWAY" ]
    then
	if [ $MSG -ne 1 ]
	then
	    print "No network set"
	fi
	MSG=1
	sleep 1
	network_wait
    else
	ping_ns
    fi
}

function ping_ns
{
    if ping -q -w 1 -c1 ${GATEWAY} &> /dev/null
    then
	if ping -q -w 1 -c1 ${REMOTE_IP} &> /dev/null
	then
	    ping_network
	else
	    ns_connect
	fi
    else
        if [ $MSG -ne 3 ]
	then
	    print "Failed to contact gateway"
	fi
	MSG=3
	sleep 1
	ping_ns
    fi
}

function ns_connect
{
    print "Executing ns_auth"
    ns_auth
    sleep 1
    ping_network
}

function ping_network
{
    if ping -q -w 1 -c1 ${REMOTE_IP} &> /dev/null
    then
        if [ $MSG -ne 2 ]
	then
	    print "Network up"
	fi
	sleep 4
	MSG=2
	ping_network
    else
        print "Failed to contact network"
	ping_ns
    fi
}

function print
{
    logger "Netsoul: $1"
}

network_wait
