#stop default docker daemon, which is running as a service
sudo service docker stop

# start new daemon, connected to consul. Required for swarm to work correctly
sudo docker daemon --label name=mcdg-centos-71939519 -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store consul://159.122.251.69:8500 --cluster-advertise eth0:2375