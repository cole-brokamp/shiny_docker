#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [[ $# < 1 ]]; then
        echo "dockerizes shiny app in current folder"
        echo "copies image to remote server and starts a container"
        echo "usage: docker_shiny_push <ssh-server-hostname>"
        exit 0
fi

SERVER=$1

# create Dockerfile
echo "FROM colebrokamp/shiny:latest" > Dockerfile

# copy Conf file
cp /Users/cole/Documents/Biostatistics/_CB/shiny_docker/shiny-server.conf ./shiny-server.conf

# get name based on folder
af=`basename ${PWD//+(*\/|\.*)}`
# build it
docker build -t cole/${af}:latest .

# get most recently built docker image id
did=`docker images -q cole/${af}:latest`

# send to server and load it (use pv to get ETA and progress)
docker save cole/${af}:latest | pv -w 80 -s `docker inspect -f '{{ .Size }}' $did` | ssh amazon_shiny2 'docker load'

# set proxy env variables in shell and run image with them
ssh -T $SERVER << HERE
      . ./proxy.sh
      docker run -d --name $af -p 0:3838 -e http_proxy -e https_proxy cole/${af}:latest
      echo "cole/${af}:latest"
      echo "running as"
      echo "$af"
      echo "on port"
      docker port $af | sed -n 's/.*://p'
HERE

# if everything completed okay, then remove the image locally to save space
docker rmi $did
docker_clean
