export DOCKER_HOST=tcp://159.122.251.69:8333
docker-compose -f docker-compose-blmxhost.yml scale sematext-agent=2
