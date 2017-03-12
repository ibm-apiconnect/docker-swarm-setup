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

# Load config
if [ ! -z "$SWARM_SETUP_CFG" ] && [ -f "$SWARM_SETUP_CFG" ]; then
  source "$SWARM_SETUP_CFG"
else
  source config
fi

echo "Build Dockerfile"
docker build -t "$dockerImageName" "$dockerFileDir"
echo "Applying tag"
docker tag "$dockerImageName" "$registryFQDN:5000/$dockerImageName"
echo "Pushing to registry..."
docker push "$registryFQDN:5000/$dockerImageName"

echo "Push complete"
exit 0
