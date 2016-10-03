#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [[ $# > 0 ]]; then
        echo "copies most recently built docker image to amazon shiny server"
        echo "usage: docker_shiny_push"
        exit 0
fi

SERVER=amazon-shiny2

# get name based on folder
af=`basename ${PWD//+(*\/|\.*)}`

# get most recently built docker image id
export did=`docker images -q cole/${af}:latest`

# send to server and load it (use pv to get ETA and progress)
docker save cole/${af}:latest | pv -w 80 -s `docker inspect -f '{{ .Size }}' $did` | ssh $SERVER 'docker load'
