#!/bin/bash
# Setup host to use registry certificate

# 1 - FQDN/IP Address
# 2 - Private Key path
# 3 - Certificate file
# 4 - User account
# 5 - With key (boolean flag)

# Load the config to get the registry domain and address
if [ ! -z "$SWARM_SETUP_CFG" ] && [ -f "$SWARM_SETUP_CFG" ]; then
  source "$SWARM_SETUP_CFG"
else
  source config
fi

usage="$(basename "$0") <FQDN> <keypair> <certpair> [username] [withkey]

where:
     <FQDN> - The FQDN address of the machine OR the IP address.
     <keypair> - The public/private keypair for SSH remoting to the machine
     <certpair> - The certificate to trust for use with the registry.
     [username] - The optional username for SSH auth. \"root\" by default.
     [withkey] - If set, copy the <certpair>.key as well."

if [ "$#" -lt 4 ]; then
  printf "Error in create-swarm-registry.sh\n%s\n" "$usage" >&2;
  exit 1;
fi
fqdn=$1
keypair=$2
certpair=$3
if [ -z "$4" ]; then
  user="root"
else
  user=$4
fi

# Check if certificates exist
certerr="Error: Ensure both $certpair.crt and $certpair.key exist!";
if [ ! -f "$certpair.crt" ] || [ ! -f "$certpair.key" ]; then
  echo $certerr
  printf "Error in create-swarm-registry.sh\n%s\n" "$usage" >&2;
  exit 1;
else
  certdir="/etc/docker/certs.d"
  regcertdir="$certdir/$fqdn:5000"
  # Chown the /etc/docker directory for the user, then
  # create the appropriate certificate directories and populate them.
  own="sudo chown -R $user /etc/docker";
  ssh "$user@$fqdn" $own
  mkcertdir="if [ ! -d $certdir ]; then
    echo 'creating $certdir';
    mkdir $certdir;
  fi;
  if [ ! -d $regcertdir ]; then
      echo 'creating $regcertdir';
      mkdir $regcertdir;
  fi;"
  ssh "$user@$fqdn" $mkcertdir;
  echo "Copying $certpair.crt to $fqdn"
  scp "$certpair.crt" "$user@$fqdn:$regcertdir"

  # If the last param exists, then copy the key as well.
  if [ ! -z "$5" ]; then
    echo "Copying $certpair.key to $fqdn"
    scp "$certpair.key" "$user@$fqdn:$regcertdir"
  fi
fi
exit 0;
