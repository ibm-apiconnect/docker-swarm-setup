#!/bin/bash

# Licensed Materials - Property of IBM
# 5725-L30, 5725-Z22
#
# (C) Copyright IBM Corporation 2017
#
# All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.

# Create a Docker Host

usage="$(basename "$0") [-hup] -n <vm-name> -i <ip-address> -k <ssh-private-key> -- Create a Docker Host VM

where:
    -h  show this help text
    -n  the name of the Docker Host to create
    -i  the IP Address of the target machine
    -u  the user for the ssh session
    -k  the SSH private key for the session
    -p  the SSH port used for the session
    -e  the Docker engine port to use for the host"
vmname=""
ipaddr=""
keypath=""
user="root"
port="22"
engineport="2376"
if [ $# -lt 3 ]; then
  echo "$usage"
  exit 1
fi
while getopts ':h:n:i:u:k:p:R:' option; do
  case "$option" in
    R) registry=$OPTARG
       ;;
    e) engineport=$OPTARG
       ;;
    h) echo "$usage"
       exit
       ;;
    i) ipaddr=$OPTARG
       ;;
    k) keypath=$OPTARG
       ;;
    n) vmname=$OPTARG
       ;;
    p) port=$OPTARG
       ;;
    u) user=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift "$((OPTIND - 1))"
if [ -z "$registry" ]; then
  docker-machine create --driver generic \
  --generic-engine-port "$engineport" \
  --generic-ip-address "$ipaddr" \
  --generic-ssh-key "$keypath" \
  --generic-ssh-user "$user" \
  --generic-ssh-port "$port" \
  "$vmname"
else
  docker-machine create --driver generic \
  --generic-engine-port "$engineport" \
  --generic-ip-address "$ipaddr" \
  --generic-ssh-key "$keypath" \
  --generic-ssh-user "$user" \
  --generic-ssh-port "$port" \
  --engine-insecure-registry "$registry" \
  "$vmname"
fi
