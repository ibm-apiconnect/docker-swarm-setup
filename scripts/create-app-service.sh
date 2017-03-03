#!/bin/bash
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
