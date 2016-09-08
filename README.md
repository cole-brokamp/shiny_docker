# shiny_docker

[![](https://images.microbadger.com/badges/image/colebrokamp/shiny.svg)](https://microbadger.com/images/colebrokamp/shiny)
[![](https://images.microbadger.com/badges/version/colebrokamp/shiny.svg)](https://hub.docker.com/r/colebrokamp/shiny/)

> A robust method to automatically dockerize your R Shiny Application

## About

#### Image Contents

The Dockerfile here is used to build the `colebrokamp/shiny` image. It contains R and Shiny Server.  It also contains the R packages `shiny` and `rmarkdown`, my custom R package (`github.com/cole-brokamp/CB`); and the 
geospatial R packages `rgeos` and `rgdal` (including the `gdal`, `geos`, and `proj4` software libraries); `hadley/tidyverse` for the core tidyverse packages (ggplot2, dplyr, tidyr, readr, purrr, tibble, modelr, 
broom, and more); and `cole-brokamp/automagic` is also included for automatic installation of required R packages.

This image is fairly large but will only need to be pulled the first time a Docker container is built using the image.  Alternatively, pull the image from DockerHub ahead of time with `docker pull colebrokamp/shiny`.

#### How It Works

Several things happen when this base image is used to generate a dockerized shiny application by using `ONBUILD` commands in the Dockerfile for `colebrokamp/shiny`.

**Application Code/Data**: The contents of the entire build context (i.e. the working directory) are copied to `/srv/shiny-server/app/`. Note that *all* the contents of the working directory are copied to the Docker daemon. To speed up the build time, keep only files necessary for the Shiny app alongside the Dockerfile in the working directory.

**Installing Necessary R Packages**: The `automagic` R package ([www.github.com/cole-brokamp/automagic](www.github.com/cole-brokamp/automagic)) scans the code inside the directory for necessary packages and installs them when building the Docker image so that no other customization should be necessary.

**Shiny Server Configuration**: By default, a simple `shiny-server.conf` is downloaded from this github repository (`example_shiny-server.conf`) and copied to `/etc/shiny-server/shiny-server.conf`. This file has two important differences from the default config file installed by shiny:  (1) It runs all R processes as the user `docker` instead of `shiny` and (2) it only serves one application (`/srv/shiny-server/app`) instead of hosting the entire directory. To use a custom configuration file, include a file in the app directory called `shiny-server.conf`. If this file is present, it will be copied to `/etc/shiny-server/shiny-server.conf` instead of downloading and using the example configuration file. See more details on server configuration [here](http://docs.rstudio.com/shiny-server/#server-management).

## Dockerizing Your Shiny Application

Create a Dockerfile inside the shiny app directory that contains only `FROM colebrokamp/shiny:latest`:

```
echo "FROM colebrokamp/shiny:latest" > Dockerfile
```

Build your app with:

```
docker build -t <app-name> .
```
Create a docker container running the application with `docker run -d -p 3838:3838 <app-name>`. Open `localhost:3838` to view the app. Note that only one docker container can be bound to a single port, so if using multiple containers to run multiple shiny apps at the same time, you will need to bind to host port other than 3838.

## Example Usage

This example builds a docker image for the shiny app in the directory `hello_shiny`. If you want to try the example yourself, clone the repository or download the example app folder.

```
git clone https://github.com/cole-brokamp/shiny_docker
cd shiny_docker/hello_shiny
echo "FROM colebrokamp/shiny:latest" > Dockerfile
docker build -t hello_shiny .
```
Run the example shiny application with `docker run -d -p 3838:3838 hello_shiny` and visit `localhost:3838` to view the application.

## Test Running the Image

Running this image won't start shiny server because it has no `ENTRYPOINT` or `CMD` as it was intended to be imported for use in other images. To test that it is working, run a container with `docker run --rm -p 3838:3838 colebrokamp/shiny bash -c "exec shiny-server"` and visit `localhost:3838` in your browser.

## Deploying to Server

These instructions are mainly aimed at my personal use for deploying to an internal server with some strict proxy access rules.

#### Automated Deployment Scripts

Use the scripts in the [deployment_scripts](deployment_scripts) folder to automate the entire process:

`docker_shiny_build.sh`:
- makes Dockerfile
- copies custom `shiny-server.conf` file
- makes app name based on name of current folder
- builds the image as `cole/<app-folder>:latest`
- exports `af` and `did` to the shell as the name of the app and the docker image id, respectively

`docker_shiny_push.sh <ssh-server-name>`:
- depends on `af` and `did`
- saves the docker image
- sends it to the specified remote server with a progress bar
- exports `SERVER` as which server it was told to send to

`docker_shiny_run.sh <virtual-host-name>`:
- depends on `SERVER`
- exports proxy variables in shell on server
- runs image on a random, unused port using proxy variables
- also supplies `VIRTUAL_HOST` based on `<virtual-host-name>` for automated nginx reverse proxy on docker
- returns image, container, port, and virtual hostname information

`docker_shiny_clean.sh`:
- removes the local image
- runs `docker_clean`
- unsets `af`, `did`, and `SERVER`

#### Viewing the Application

To test the app without public access, use `ssh -N -L localhost:3838:localhost:<PORT> <SERVER>` to map port <PORT> on the server to local port 3838. Then app will be available at `localhost:3838`
