#!/bin/bash

# set default container name
name=${1:-none}

# remove container image
docker ps -a | grep "Exited" | awk '{print $1 }' |xargs docker stop
docker ps -a | grep "Exited" | awk '{print $1 }' |xargs docker rm
docker images| grep $name | awk '{print $3 }' |xargs docker rmi
