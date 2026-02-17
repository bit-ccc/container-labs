#!/bin/bash

set -euo pipefail

# Prompt the user for confirmation
read -p "WARNING: This will permanently remove all Docker containers (running or not), images, volumes, and networks. Are you sure? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted."
    exit 1
fi

# Stop all running containers
echo "Stopping all running containers..."
if [ "$(docker ps -q)" ]; then
    docker stop $(docker ps -q)
else
    echo "No running containers to stop."
fi

# Prune everything
echo "Removing all containers, images, volumes, and networks..."
docker system prune -a --volumes -f
docker volume prune -a -f

echo "Docker resources purged successfully."
