#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

## dockerizes shiny app in current folder

# create Dockerfile
echo "FROM colebrokamp/shiny:latest" > Dockerfile

# copy Conf file
cp /Users/cole/Documents/Biostatistics/_CB/shiny_docker/shiny-server.conf ./shiny-server.conf

# get name based on folder
export af=`basename ${PWD//+(*\/|\.*)}`
# build it
docker build -t cole/${af}:latest .

# get most recently built docker image id
export did=`docker images -q cole/${af}:latest`
