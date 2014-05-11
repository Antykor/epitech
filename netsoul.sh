#!/bin/bash
#
# Description: Bash script to connect automatically to the netsoul server
# This script implies using a modified ns_auth
#
# Written By: Alpha14 (contact@alpha14.com)
# Version: 5 (5-2014)

remote_ip="google.fr"
msg=0
verbose='false'
user=''

# Arguments
while getopts 'u:v' flag; do
  case "${flag}" in
    u) user=${OPTARG} ;;
    v) verbose='true' ;;
    *) echo "Unexpected option ${flag}" ;;
  esac
done

control_c()
{
    message "Exiting (SIGINIT)"
    exit $?
}

# Trap keyboard interrupt (CTRL+C)
trap control_c SIGINT

network_wait()
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

ping_ns()
{
    if ping -q -w 3 ${gateway} &> /dev/null
    then
	if ping -q -w 3 ${remote_ip} &> /dev/null
	then
	    ping_network
	else
	    ns_connect
	fi
    else
	print "Failed to contact gateway" 2
	sleep 1
	network_wait
    fi
}

ns_connect()
{
    #print "Executing ns_auth" 3
    if [ -n "$user" ]
    then
	message "Launching ns_auth with user $user"
	ns_auth -u $user
    else
	message "Launching ns_auth"
	ns_auth
    fi
    sleep 1
    ping_network
}

ping_network()
{
    if ping -q -w 3 ${remote_ip} &> /dev/null
    then
	print "Network up" 4
	sleep 4
	ping_network
    else
        print "Failed to contact network" 5
	ping_ns
    fi
}

print()
{
    if [ $msg -ne $2 ]
    then
	logger "Netsoul: $1"
	if [ "$verbose" = true ]
	then
	    echo "Netsoul: $1"
	fi
	notify-send 'Netsoul' "$1" --icon=dialog-information -t 2000
    fi
    msg=$2
}

message()
{
    if [ "$verbose" = true ]
    then
	logger "Netsoul: $1"
	echo "Netsoul: $1"
    fi
}

network_wait
