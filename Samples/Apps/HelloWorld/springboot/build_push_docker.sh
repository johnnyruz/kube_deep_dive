#!/bin/bash

IMAGE_VER=myboot:v2

docker build -f Dockerfile -t dev.local/ssoutrs/$IMAGE_VER .
docker login docker.io
docker tag dev.local/ssoutrs/$IMAGE_VER docker.io/ssoutrs/$IMAGE_VER
docker push docker.io/ssoutrs/$IMAGE_VER
