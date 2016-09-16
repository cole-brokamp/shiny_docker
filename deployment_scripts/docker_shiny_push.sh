#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [[ $# < 1 ]]; then
        echo "copies image to remote server"
        echo "usage: docker_shiny_push <ssh-server-hostname>"
        exit 0
fi

export SERVER=$1

# send to server and load it (use pv to get ETA and progress)
docker save cole/${af}:latest | pv -w 80 -s `docker inspect -f '{{ .Size }}' $did` | ssh $SERVER 'docker load'
