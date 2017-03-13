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

# Create the app service in Docker Swarm

# Load config
if [ ! -z "$SWARM_SETUP_CFG" ] && [ -f "$SWARM_SETUP_CFG" ]; then
  source "$SWARM_SETUP_CFG"
else
  source config
fi

echo "Create service for $dockerImageName"
pullapp="sudo docker service create --name $dockerImageName
--replicas=3 --network mynet -p3000:3000 --constraint=node.role!=manager
$registryFQDN:5000/$dockerImageName"
ssh "$user@$manager1FQDN" $pullapp
echo "Service created."
exit 0;
