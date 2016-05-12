#!/bin/bash
# This script starts the shopping application using Docker Swarm. To cluster swarm, two nodes are required,
# a running on the 'master' node and this one running on a 'non-master' node. The master node
# will run consul (which is not clustered at this moment) and the Redis master.

echo "Running Docker daemon"
./run-daemon-host240.sh &
sleep 20

echo "Cleaning up - removing all Docker containers"
./remove-docker-containers.sh

echo "Joining the Swarm"
cd ..
./join-swarm.sh
sleep 5
