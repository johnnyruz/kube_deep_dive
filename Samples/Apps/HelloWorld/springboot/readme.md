Initial pom.xml created by start.spring.io

mvn clean compile package

java -jar target/boot-demo-1.0.0.jar
or
mvn spring-boot:run
curl http://localhost:8080/
ctrl-c

Manual Deployment

export IMAGE_VER=boot-demo:1.0.0

docker build -f Dockerfile -t dev.local/ssoutrs/$IMAGE_VER .
docker login docker.io
docker tag dev.local/ssoutrs/$IMAGE_VER docker.io/ssoutrs/$IMAGE_VER
docker push docker.io/ssoutrs/$IMAGE_VER

