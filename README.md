Running on Docker Swarm

The original repo for the source code is here: git clone https://github.com/bijukunjummen/shopping-cart-cf-app.git

I got Docker Swarm running on my 2 virtual Bluemix hosts, as follows.

If using the shopping-cart-cf-app Spring project, the consul docker-compose file is in the 'consul' directory, and the 'swarm' directory contains the scripts for docker daemon and swarm join/manage.

Consul
Create a docker-compose-consul.yml file as follows, and 'up' it on one of the hosts:

version: '2'

services:
  myconsul:
    image: progrium/consul
    restart: always
    hostname: consul
    ports:
      - 8500:8500
    command: "-server -bootstrap"

Docker Daemon
Restart the docker daemon with the -H settings below:

sudo service docker stop
sudo docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store consul://159.122.251.69:8500 --cluster-advertise eth0:2375

Swarm
On each host, run the following to 'join' to the swarm. The IP address of consul should match the host server where consul is running, and the host addr of the 'join' command should match the current host:

docker run -d swarm join --addr=159.122.251.69:2375 consul://159.122.251.69:8500/swarm

On one of the hosts, run the swarm manager:

docker run -d -p 8333:2375 swarm manage consul://159.122.251.69:8500/swarm

I believe the swarm port here (8333) can be anything, but it must map to 2375, which is the docker daemon port.

Check that the swarm is running. This connects to the swarm manager daemon and should display the info below. The bolded entries are swarm specific - if they are not there you are not seeing the swarm status. Under Nodes you should also see host names (not just IP addresses), and a status of 'Healthy':

docker -H tcp://159.122.251.69:8333 info

Containers: 10
 Running: 7
 Paused: 0
 Stopped: 3
Images: 29
Server Version: swarm/1.2.2
Role: primary
Strategy: spread
Filters: health, port, containerslots, dependency, affinity, constraint
Nodes: 2
 mcdg-centos-71939519: 159.122.251.69:2375
  └ ID: MU2I:UHBR:UKF4:LPR6:3OYE:XCIX:PJ5D:TYT2:3BXJ:RVOC:GGZQ:P6J6
  └ Status: Healthy
  └ Containers: 3
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 3.888 GiB
  └ Labels: executiondriver=, kernelversion=3.10.0-229.1.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ Error: (none)
  └ UpdatedAt: 2016-05-10T23:59:24Z
  └ ServerVersion: 1.11.1
 mcdg-centos-75880098: 159.122.251.240:2375
  └ ID: JYWF:HXWL:PZP6:65NG:G5T4:PZ24:IYEC:QNG5:MWS2:HBSC:XOQS:2RHH
  └ Status: Healthy
  └ Containers: 7
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 3.888 GiB
  └ Labels: executiondriver=, kernelversion=3.10.0-229.1.2.el7.x86_64, operatingsystem=CentOS Linux 7 (Core), storagedriver=devicemapper
  └ Error: (none)
  └ UpdatedAt: 2016-05-10T23:59:30Z
  └ ServerVersion: 1.11.1
.
.
.

Running the SHOP application
If using the shopping-cart-cf-app Spring project, the scripts mentioned below are in the 'shop-on-swarm' directory

The docker-compose-blmxhost.yml will run the application on my 2 Bluemix virtual servers, on a Swarm cluster. Compared to the standard docker-compose.yml file there are 

Make sure Redis master runs on a specific host. This is because the application connects to this host specifically, as configured in the bootInDocker.sh. I don't like this but haven't had the time to fix it so that the app uses Docker DNS and networking to find Redis:

    environment:
      - constraint:node==mcdg-centos-71939519

SPM
I run SPM as part of the docker-compose file, as follows:

  sematext-agent:
    image: 'sematext/sematext-agent-docker:latest'
    environment:
      - LOGSENE_TOKEN=ffb28044-957d-4d1e-b78e-0a1eafb1cdbc
      - SPM_TOKEN=0f31bb82-a715-44f8-914d-ef6f11b52061
      - affinity:container!=sematext-agent*
    privileged: true
    restart: always
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'

Note the 'affinity' filter; this allows me to scale the SPM agent to run on each host, and each instance will start on a separate host. 

I scale it manually at the moment, but this could be scaled using a script that counts the number of hosts:

docker-compose scale sematext-agent=2

Docker-Compose
To run the docker-compose file on Swarm, you need to set the DOCKER_HOST to point to Swarm, as follows:

export DOCKER_HOST=tcp://159.122.251.69:8333
docker-compose up

Same goes for stopping the application:

export DOCKER_HOST=tcp://159.122.251.69:8333
docker-compose down
