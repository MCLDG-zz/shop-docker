export DOCKER_HOST=tcp://159.122.251.69:8333
docker-compose -f docker-compose-blmxhost.yml scale shop1=4
docker-compose -f docker-compose-blmxhost.yml scale shop2=3
