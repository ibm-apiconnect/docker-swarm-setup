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

# Create the Swarm Registry

# 1 - Name
# 2 - FQDN/IP Address
# 3 - Private Key path
# 4 - Certificate key/cert name
# 5 - User account

usage="$(basename "$0") <name> <FQDN> <keypair> <certpair> [username]

where:
     <name> - The name to give this machine in Docker.
     <FQDN> - The FQDN address of the machine OR the IP address.
     <keypair> - The public/private keypair for SSH remoting to the machine
     <certpair> - The certificate and key for the Docker Registry
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

# Provision the registry.
sh "$libPath/create-docker-host.sh" -n "$name" -i "$fqdn" -k "$keypair" \
-u "$user"

# Copy cert and key to registry
sh "$libPath/setup-cert-on-host.sh" "$fqdn" \
"$keypair" "$certpair" "$user" 1

# Start the registry container
echo "Check if registry container exists on $name"
ssh "$user@$fqdn" 'sudo docker ps -a | grep registry'
regCheck=$?
if [ "$regCheck" -eq 0 ]; then
  echo "Registry container already exists";
else
  echo "Copying certificates"
  # Get working directory in remote machine
  workdir=$(ssh "$user@$fqdn" pwd)
  certdir="$workdir/certs"
  echo "Creating $certdir directory"
  mkcertdir="if [ ! -d $certdir ]; then
    mkdir $certdir;
  fi"
  ssh "$user@$fqdn" $mkcertdir
  scp "$certpair.crt" "$user@$fqdn:$certdir"
  scp "$certpair.key" "$user@$fqdn:$certdir"
  # Get basenames of certpair
  certname=$(basename "$certpair.crt")
  keyname=$(basename "$certpair.key")
  echo "Creating container"
  mkreg="sudo docker run -d -p 5000:5000 --restart=always \
    --name registry \
    -v $certdir:/certs \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/$certname \
    -e REGISTRY_HTTP_TLS_KEY=/certs/$keyname \
    registry:2";
  ssh "$user@$fqdn" $mkreg
  fi
