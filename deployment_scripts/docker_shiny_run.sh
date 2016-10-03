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
      docker run -d --name $af -e http_proxy -e https_proxy -e VIRTUAL_HOST=$VH.amazon-shiny.duckdns.org cole/${af}:latest
HERE

echo "proxied with the virtual host name"
echo "$VH"
