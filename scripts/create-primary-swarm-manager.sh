#!/bin/bash

# Licensed Materials - Property of IBM
# 5725-L30, 5725-Z22
#
# (C) Copyright IBM Corporation 2017
#
# All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
# Setup host to use registry certificate

# Create the primary swarm manager

# 1 - Name
# 2 - FQDN/IP Address
# 3 - Private Key path
# 4 - Certificate file
# 5 - User account

# Load config
if [ ! -z "$SWARM_SETUP_CFG" ] && [ -f "$SWARM_SETUP_CFG" ]; then
  source "$SWARM_SETUP_CFG"
else
  source config
fi

usage="$(basename "$0") <name> <FQDN> <keypair> <certpair> [username]

where:
     <name> - The name to give this machine in Docker.
     <FQDN> - The FQDN address of the machine OR the IP address.
     <keypair> - The public/private keypair for SSH remoting to the machine
     <certpair> - The certificate to trust for use with the registry.
     [username] - The optional username for SSH auth. \"root\" by default."

if [ "$#" -lt 4 ]; then
  printf "Error in create-swarm-registry.sh\n%s\n" "$usage" >&2;
  exit 1;
fi
name=$1
fqdn=$2
keypair=$3
certpair=$4
if [ -z "$5" ]; then
  user="root"
else
  user=$5
fi

libPath="lib"

if [ -z "$useInsecureRegistry" ]; then
  # Provision the manager.
  sh "$libPath/create-docker-host.sh" -n "$name" -i "$fqdn" -k "$keypair" \
    -u "$user"
  # Copy certpair to manager
  sh "$libPath/setup-cert-on-host.sh" "$fqdn" "$keypair" "$certpair" "$user"
else
# Provision the manager.
  sh "$libPath/create-docker-host.sh" -n "$name" -i "$fqdn" -k "$keypair" \
  -u "$user" -R "$registryFQDN:5000"
fi


# Setup instance as Swarm Manager
init="sudo docker swarm init --advertise-addr $fqdn"
ssh "$user@$fqdn" $init

# Retrieve the join commands for workers and managers
workercmd="sudo docker swarm join-token -q worker"
workertoken=$(ssh "$user@$fqdn" $workercmd)
managercmd="sudo docker swarm join-token -q manager"
managertoken=$(ssh "$user@$fqdn" $managercmd)

# Generate the commands to join managers and workers and save to disk.

echo "sudo docker swarm join --token $workertoken $fqdn:2377" > workerjoin
echo "sudo docker swarm join --token $managertoken $fqdn:2377" > managerjoin
