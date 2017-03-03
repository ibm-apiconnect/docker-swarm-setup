#!/bin/bash

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
