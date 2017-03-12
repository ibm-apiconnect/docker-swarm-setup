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

# Check things before starting

# Load config
if [ ! -z "$SWARM_SETUP_CFG" ] && [ -f "$SWARM_SETUP_CFG" ]; then
  echo "Using $SWARM_SETUP_CFG"
  source "$SWARM_SETUP_CFG"
else
  echo "Using ./config."
  source config
fi

fail=0
msg=""

# SSH keys
echo "Checking SSH keys"
if [ ! -f "$keypair" ]; then
  fail=1;
  msg="$msg'$keypair' was not found!\n";
fi
if [ ! -f "$keypair.pub" ]; then
  fail=1;
  msg="$msg'$keypair.pub' was not found!\n";
fi
echo "Checking certs"
# Certs
if [ ! -f "$cert.crt" ]; then
  fail=1;
  msg="$msg'$cert.crt' was not found!\n";
fi
if [ ! -f "$cert.key" ]; then
  fail=1;
  msg="$msg'$cert.key' was not found!\n";
fi

# Auto-add keys to known_hosts to avoid prompts during script run.
echo "Adding hosts to known_hosts..."
echo "WARNING: This step is only for demonstrative purposes, and should never be
done without caution on live systems, as it leaves potential for man-in-the-middle attacks!"
hosts=( "$registryFQDN" "$manager1FQDN" "$manager2FQDN" "$worker1FQDN" "$worker2FQDN" "$worker3FQDN" );
for i in "${hosts[@]}"
do
  ssh-keygen -R $i &> /dev/null
  keyscan=$(ssh-keyscan -t ecdsa $i 2> /dev/null)
  if [ -z "$keyscan" ]; then
    fail=1
    msg="$msg\0Could not add $i to known_hosts, ssh-keyscan returned no results.\n"
  else
    echo "$keyscan" >> "$HOME/.ssh/known_hosts"
  fi
done

# Test SSH user + key
echo "Checking logins"
hosts=( "$registryFQDN" "$manager1FQDN" "$manager2FQDN" "$worker1FQDN" "$worker2FQDN" "$worker3FQDN" );
for i in "${hosts[@]}"
do
  ssh "$user"@"$i" 'echo "test"' &> /dev/null
  result=$?
  # If the SSH fails, then the credentials aren't valid.
  if [ $result -ne 0 ]; then
    msg="$msg\0SSH login fails for machine at '$i'\n";
  fi
done


# If anything failed, print out the failure and exit
if [ $fail -ne 0 ]; then
  echo "=============================="
  echo "CONFIGURATION ERRORS DETECTED"
  echo "==============================\n"
  echo "$msg"
  echo "=============================="
  echo "Please correct these configuration issues and try again."
  exit 1 
else
  echo "Prelaunch check complete."
  exit 0
fi
