#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [[ $# < 1 ]]; then
        echo "runs docker image on remote server"
        echo "usage: docker_shiny_run <virtual-host-name>"
        exit 0
fi

VH=$1

# set proxy env variables in shell and run image with them
ssh -T $SERVER << HERE
      . ./proxy.sh
      docker run -d --name $af -p 0:3838 -e http_proxy -e https_proxy -e VIRTUAL_HOST=$VH cole/${af}:latest
      echo "cole/${af}:latest"
      echo "running as"
      echo "$af"
      echo "on port"
      docker port $af | sed -n 's/.*://p'
HERE

echo "proxied with the virtual host name"
echo "$VH"
