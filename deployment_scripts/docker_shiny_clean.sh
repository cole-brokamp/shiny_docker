#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

## removes image created by docker_shiny scripts

# if everything completed okay, then remove the image locally to save space
docker rmi $did
unset af did SERVER
docker_clean
