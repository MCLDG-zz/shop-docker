#!/bin/bash
# This script starts the shopping application using Docker Swarm. To cluster swarm, two nodes are required,
# with this script running on the 'master' node and the other running on a 'non-master' node. The master node
# will run consul (which is not clustered at this moment) and the Redis master.

chmod -R 755 ./

echo "Running Docker daemon"
./run-daemon-host69.sh &
sleep 20

echo "Cleaning up - removing all Docker containers"
./remove-docker-containers.sh

echo "Running Consul"
cd consul
./run-consul.sh &

read -n1 -r -p "Now run the accompanying script (start-all-host240.sh) on the non-master node. Once you have done this, press any key to continue..." key

echo "Joining and Managing Swarm"
cd ..
./join-swarm-host69.sh
sleep 5
./manage-swarm.sh
sleep 5

echo "Running the shopping app on the Swarm"
cd shop-on-swarm
./run-on-swarm.sh
