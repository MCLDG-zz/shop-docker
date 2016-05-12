Running on Docker Swarm
=======================
Here are the instructions to get Docker Swarm running on my 2 virtual Bluemix hosts. Host details are as follows:

mcdg-centos-71939519: 159.122.251.69
mcdg-centos-75880098: 159.122.251.240

Pre-requisites
--------------
Firstly, on each Docker host, clone the git repo: https://github.com/MCLDG/shop-docker.git
Make sure docker and docker-compose are installed, and that the docker daemon is running (it should run as a service - `sudo service docker start`)

Consul
------
On one of the hosts, in the consul directory, start consul using docker-compose: `docker-compose -f docker-compose-consul.yml up -d`
At this stage we are not running a Consul cluster, so just one instance is required.

Run the following scripts on each host

Docker Daemon
-------------

Restart the docker daemon: `swarm/run-daemon.sh`

The daemon settings ensure it uses Consul:

`sudo docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store consul://159.122.251.69:8500 --cluster-advertise eth0:2375`

Note that once you do this the usual docker commands will no longer work as they won't be able to find the daemon.
So you need to either pass '-H tcp://159.122.251.69:2375' to each docker command, or set the DOCKER_HOST, as in:
`export DOCKER_HOST=tcp://159.122.251.69:2375`

Swarm
-----
On each host, run the following to 'join' to the swarm. The IP address of consul should match the host server where consul is running, and the host addr of the 'join' command should match the current host:

```
docker run -d swarm join --addr=159.122.251.69:2375 consul://159.122.251.69:8500/swarm
```
or use the script in `swarm/join-swarm.sh` - note, make sure to change the IP address so that it matches the current docker host

On one of the hosts, run the swarm manager:

```
docker run -d -p 8333:2375 swarm manage consul://159.122.251.69:8500/swarm
```
or use the script in `swarm/manage-swarm.sh`

I believe the swarm port here (8333) can be anything, but it must map to 2375, which is the docker daemon port.

Note that after you start Swarm you now have two different ports that will provide different information in response to docker commands. Port 2375 will respond with a host-specific view (i.e. the current host), whereas port 8333 will respond with a Swarm view, i.e. all Swarm hosts.
So to receive a Swarm response you need to either pass '-H tcp://159.122.251.69:8333' to each docker command, or set the DOCKER_HOST, as in:
```
export DOCKER_HOST=tcp://159.122.251.69:8333
```

Check that the swarm is running. This connects to the swarm manager daemon and should display the info below. The bolded entries are swarm specific - if they are not there you are not seeing the swarm status. Under Nodes you should also see host names (not just IP addresses), and a status of 'Healthy':

```
docker -H tcp://159.122.251.69:8333 info
```

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
----------------------------
If using the shopping-cart-cf-app Spring project, the scripts mentioned below are in the `shop-on-swarm` directory

The `docker-compose-blmxhost.yml` will run the application on my 2 Bluemix virtual servers, on a Swarm cluster. Compared to the standard docker-compose.yml file the only change is to pin the Redis master to a specific host.

Make sure Redis master runs on a specific host. This is because the application connects to this host specifically, as configured in the bootInDocker.sh. I don't like this but haven't had the time to fix it so that the app uses Docker DNS and networking to find Redis:

    environment:
      - constraint:node==mcdg-centos-71939519

SPM
---
I run SPM as part of the docker-compose file, as follows, so no need to start this separately. However, you will need to scale it depending on the number of Docker hosts you are running, so that an agent runs on each host:

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

```
docker-compose scale sematext-agent=2
```

Docker-Compose
--------------
To run the docker-compose file on Swarm, you need to set the DOCKER_HOST to point to Swarm, as follows:

```
export DOCKER_HOST=tcp://159.122.251.69:8333
docker-compose up
```

Same goes for stopping the application:
```
export DOCKER_HOST=tcp://159.122.251.69:8333
docker-compose down
```
Reference
---------
The original repo for the Shopping Cart source code is here: 
```
git clone https://github.com/bijukunjummen/shopping-cart-cf-app.git
```

Troubleshooting
---------------
It took some time to get the node constraint working for Redis; I wanted to pin Redis to a specific host since the Sring application automatically looked for it there. I tried various options and combinations of labels and constraints, and found the following to work.

I had to define a label on the docker daemon (which you can see if you run `docker info`), but the label name cannot be `node`. If you check the docker swarm source code, it seems to throw an exception if a constraint is applied using the keyword `node`. So I used `name` instead, as in:
```
sudo docker daemon --label name=mcdg-centos-71939519 -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store consul://159.122.251.69:8500 --cluster-advertise eth0:2375
```

Now when you run Redis you need to apply the constraint. I applied it using an environment constraint in the docker-compose file, as follows:

```
  redis:
    image: redis
    hostname: redis
    ports:
      - "6379:6379"
    environment:
      - constraint:name==mcdg-centos-71939519
```

Note: make sure you use '==' in the docker-compose or docker run statement, and '=' in the --label parameter in the docker daemon command.