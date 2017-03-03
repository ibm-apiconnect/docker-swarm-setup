#!/bin/bash
# Remove the swarm and docker-machine setup

# Load config
if [ ! -z "$SWARM_SETUP_CFG" ] && [ -f "$SWARM_SETUP_CFG" ]; then
  echo "Using $SWARM_SETUP_CFG"
  source "$SWARM_SETUP_CFG"
else
  echo "Using ./config."
  source config
fi

echo "==========================="
echo "== Docker Swarm Teardown =="
echo "==========================="

hosts=( "$registryFQDN" "$manager1FQDN" "$manager2FQDN" "$worker1FQDN" "$worker2FQDN" "$worker3FQDN" );
names=( "$registryName" "$manager1Name" "$manager2Name" "$worker1Name" "$worker2Name" "$worker3Name" );

echo "Disabling swarm service for $dockerImageName"
rmService="sudo docker service rm $dockerImageName"
ssh "$user@$manager1FQDN" $rmService

for i in "${hosts[@]}"
do
  echo "Remove $i from swarm"
  ssh "$user@$i" 'sudo docker swarm leave -f'
done
for i in "${names[@]}"
do
  echo "Remove $i from docker-machine"
  docker-machine rm -f $i
done

echo 'Deleting Docker Registry'
ssh "$user@$registryFQDN" 'sudo docker kill registry; sudo docker rm registry'
echo "Complete!"
