#!/bin/bash
#
# Description: Bash script to connect automatically to the netsoul server
# This script implies using a modified ns_auth
#
# Written By: Alpha14 (contact@alpha14.com)
# Version: 3 (4-2014)

remote_ip="8.8.4.4"
msg=0
verbose='false'
user=''

while getopts 'u:v' flag; do
  case "${flag}" in
    u) user=${OPTARG} ;;
    v) verbose='true' ;;
    *) echo "Unexpected option ${flag}" ;;
  esac
done

function network_wait
{
    gateway=$(ip r | awk '/^def/{print $3}')
    if [ -z "$gateway" ]
    then
	print "No network set" 1
	sleep 1
	network_wait
    else
	ping_ns
    fi
}

function ping_ns
{
    if ping -q -w 1 -c1 ${gateway} &> /dev/null
    then
	if ping -q -w 1 -c1 ${remote_ip} &> /dev/null
	then
	    ping_network
	else
	    ns_connect
	fi
    else
	print "Failed to contact gateway" 2
	sleep 1
	ping_ns
    fi
}

function ns_connect
{
    print "Executing ns_auth"
    if [ -n "$user" ]
    then
	message "launching ns_auth with $user"
	ns_auth -u $user
    else
	message "launching ns_auth"
	ns_auth
    fi
    sleep 1
    ping_network
}

function ping_network
{
    if ping -q -w 1 -c1 ${remote_ip} &> /dev/null
    then
	print "Network up" 3
	sleep 4
	ping_network
    else
        print "Failed to contact network" 4
	ping_ns
    fi
}

function print
{
    if [ $msg -ne $2 ]
    then
	logger "Netsoul: $1"
	if [ "$verbose" = true ]
	then
	    echo "Netsoul: $1"
	fi
	notify-send 'Netsoul' "$1" --icon=dialog-information -t 1800
    fi
    msg=$2
}

function message
{
    if [ "$verbose" = true ]
    then
	echo $1
    fi
}

network_wait
