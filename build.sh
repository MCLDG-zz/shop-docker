mvn package -DskipTests
docker build -t blmxmcdg/shopapp .
docker push blmxmcdg/shopapp

