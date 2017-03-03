#!/bin/bash
# The master setup script

# Load config
if [ ! -z "$SWARM_SETUP_CFG" ] && [ -f "$SWARM_SETUP_CFG" ]; then
  echo "Using $SWARM_SETUP_CFG"
  source "$SWARM_SETUP_CFG"
else
  echo "Using ./config."
  source config
fi

echo "========================"
echo "== Docker Swarm Setup =="
echo "========================"



if [ ! -z "$useInsecureRegistry" ]; then
  echo "WARNING: You have chosen to use an insecure registry. This means that
  there will be no verification that the registry used to pull images into
  your swarm is the correct registry, and is a trivially exploited security
  flaw. DO NOT USE THIS FLAG IN A REAL-WORLD ENVIRONMENT FOR ANY REASON!

  Additionally, you will need to configure your local environment
  (this machine) to allow pushing to insecure registries. For more information,
  visit https://docs.docker.com/registry/insecure"
  read -r -p "Are you sure you want to continue? [y/N] " response
  case "$response" in
      [yY][eE][sS]|[yY])
      ;;
      *)
      echo "Exiting."
      exit 0;
  esac
fi

# Pre-launch checks -- abort if we fail
sh scripts/prelaunch.sh
if [ $? -ne 0 ]; then
  exit $?
fi

# Run the setup!
echo "================================"
echo "Create swarm registry:"
echo "================================"
sh scripts/create-swarm-registry.sh "$registryName" "$registryFQDN" "$keypair" "$cert" "$user"

echo "================================"
echo "Create primary manager:"
echo "================================"
sh scripts/create-primary-swarm-manager.sh "$manager1Name" "$manager1FQDN" "$keypair" "$cert" "$user"

echo "================================"
echo "Create secondary manager:"
echo "================================"
sh scripts/create-secondary-swarm-manager.sh "$manager2Name" "$manager2FQDN" "$keypair" "$cert" "$user"

echo "================================"
echo "Create workers:\n"
echo "================================"
sh scripts/create-swarm-worker.sh "$worker1Name" "$worker1FQDN" "$keypair" "$cert" "$user" &
sh scripts/create-swarm-worker.sh "$worker2Name" "$worker2FQDN" "$keypair" "$cert" "$user" &
sh scripts/create-swarm-worker.sh "$worker3Name" "$worker3FQDN" "$keypair" "$cert" "$user" &

wait

echo "================================"
echo "Configuring manager overlay..."
echo "================================"
ssh "$user@$manager1FQDN" 'sudo docker network create -d overlay mynet'

echo "================================"
echo "Push app to swarm:"
echo "================================"
sh scripts/push-app-to-swarm.sh

echo "================================"
echo "Create app service in Swarm:"
echo "================================"
sh scripts/create-app-service.sh

echo "================================"
echo "Setup complete!"
exit 0
