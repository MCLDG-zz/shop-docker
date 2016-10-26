#this should show ps for the current host
docker -H tcp://159.122.251.69:2375 ps

#this should execute against the docker swarm and show ps for the swarm
docker -H tcp://159.122.251.69:8333 ps
