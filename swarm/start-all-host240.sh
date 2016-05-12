#!/bin/bash
# This script starts the shopping application using Docker Swarm. To cluster swarm, two nodes are required,
# a running on the 'master' node and this one running on a 'non-master' node. The master node
# will run consul (which is not clustered at this moment) and the Redis master.

chmod -R 755 ./

echo "Running Docker daemon"
./run-daemon-host240.sh &
sleep 20

echo "Cleaning up - removing all Docker containers"
./remove-docker-containers.sh
sleep 5

echo "Joining the Swarm"
./join-swarm-host240.sh
