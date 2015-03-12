#!/bin/sh
#
# Description: Bash script to connect automatically to the netsoul server
# You need a modified ns_auth to use this script
#
# Written By: Alpha14 (contact@alpha14.com)
# (1-2015)

version=5
remote_ip="google.fr"
ns_server="ns-server.epitech.net"
msg=0
verbose='false'
user=''
tries=0

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
    if ping -q -w 2 ${gateway} &> /dev/null
    then
	wait_ns
    else
	print "Failed to contact gateway"
	sleep 1
	network_wait
    fi
}


wait_ns()
{
    if ping -q -w 2 ${ns_server} &> /dev/null
    then
	ping_remote
    else
	print "Unable to join netsoul server"
	sleep 1
	ping_ns
    fi
}

ping_remote()
{
    if ping -q -w 2 ${remote_ip} &> /dev/null
    then
	ping_network
    else
	sleep 1
	ns_connect
    fi
}

ns_connect()
{

    if [ "$tries" -ge 3 ]
    then
        print "Netsoul service seems down"
	sleep 10
    else
	print "Connecting with ns_auth"
    fi

    if [ -n "$user" ]
    then
	ns_auth -u $user &> /dev/null
    else
	ns_auth &> /dev/null
    fi

    sleep 4

    if ping -q -w 2 ${remote_ip} &> /dev/null
    then
	ping_network
    else
	tries=$(( tries + 1 ))
	ping_ns
    fi
}

ping_network()
{
    if ping -q -w 3 ${remote_ip} &> /dev/null
    then
	tries=0
	print "Network up"
	sleep 4
	ping_network
    else
        print "Failed to contact network"
	ping_ns
    fi
}

print()
{
    if [ "$msg" != "$1" ]
    then
	logger "Netsoul: $1"
	if [ "$verbose" = true ]
	then
	    echo "[Netsoul] $1"
	fi
	notify-send 'Netsoul' "$1" --icon=dialog-information -t 2000
    fi
    msg=$1
}

message()
{
    if [ "$verbose" = true ]
    then
	logger "[Netsoul] $1"
	echo "[Netsoul] $1"
    fi
}

echo "[Netsoul] Script version $version, report suggestions and bugs on https://github.com/alpha14/epitech"

if ping -q -w 1 ${remote_ip} &> /dev/null
then
    ping_network
else
    network_wait
fi
