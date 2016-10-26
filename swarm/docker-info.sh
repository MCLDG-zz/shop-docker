#this should show info for the current host
docker -H tcp://159.122.251.69:2375 info

#this should execute against the docker swarm and show info for the swarm
docker -H tcp://159.122.251.69:8333 info

