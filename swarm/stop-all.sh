#!/bin/bash
# This script starts the shopping application using Docker Swarm. To cluster swarm, two nodes are required,
# with this script running on the 'master' node and the other running on a 'non-master' node. The master node
# will run consul (which is not clustered at this moment) and the Redis master.

chmod -R 755 ./

echo "Stopping the shopping app on the Swarm"
cd shop-on-swarm
./stop-on-swarm.sh
sleep 20

echo "Cleaning up - removing all Docker containers"
cd ..
./remove-docker-containers.sh
