# shiny_docker

[![](https://images.microbadger.com/badges/image/colebrokamp/shiny.svg)](https://microbadger.com/images/colebrokamp/shiny)
[![](https://images.microbadger.com/badges/version/colebrokamp/shiny.svg)](https://hub.docker.com/r/colebrokamp/shiny/)

> A robust method to automatically dockerize your R Shiny Application

## About

#### Image Contents

The Dockerfile here is used to build the `colebrokamp/shiny` image. It contains R and Shiny Server.  It also contains the R packages `shiny` and `rmarkdown`, my custom R package (`github.com/cole-brokamp/CB`); and the geospatial R packages `rgeos` and `rgdal` (including the `gdal`, `geos`, and `proj4` software libraries). `cole-brokamp/automagic` is also included for automatic installation of required R packages.

This image is fairly large (~1.4 GB) but will only need to be pulled the first time a Docker container is built using the image.  Alternatively, pull the image from DockerHub ahead of time with `docker pull colebrokamp/shiny`.

#### How It Works

Several things happen when this base image is used to generate a dockerized shiny application by using `ONBUILD` commands in the Dockerfile for `colebrokamp/shiny`.

**Application Code/Data**: The contents of the entire build context (i.e. the working directory) are copied to `/srv/shiny-server/app/`. Note that *all* the contents of the working directory are copied to the Docker daemon. To speed up the build time, keep only files necessary for the Shiny app alongside the Dockerfile in the working directory.

**Installing Necessary R Packages**: The `automagic` R package ([www.github.com/cole-brokamp/automagic](www.github.com/cole-brokamp/automagic)) scans the code inside the directory for necessary packages and installs them when building the Docker image so that no other customization should be necessary.

**Shiny Server Configuration**: By default, a simple `shiny-server.conf` is downloaded from this github repository (`example_shiny-server.conf`) and copied to `/etc/shiny-server/shiny-server.conf`. To use a custom configuration file, include a file in the app directory called `shiny-server.conf`. If this file is present, it will be copied to `/etc/shiny-server/shiny-server.conf` instead of downloading and using the example configuration file. See more details on server configuration [here](http://docs.rstudio.com/shiny-server/#server-management).

## Dockerizing Your Shiny Application

Create a Dockerfile inside the shiny app directory that contains only:

```
FROM colebrokamp/shiny:latest
```

Build your app with:

```
docker build -t <app-name> .
```
Create a docker container running the application with `docker run -d -p 3838:3838 <app-name>`. Open `localhost:3838/app` to view the app.

## Example Usage

This example builds a docker image for the shiny app in the directory `hello_shiny`. Make sure to clone the repository so the application folder and docker resources are available if you want to try the example yourself.

```
git clone https://github.com/cole-brokamp/shiny_docker
cd shiny_docker/hello_shiny
docker build -t hello_shiny .
```

Run the example shiny application with `docker run -d -p 3838:3838 hello_shiny` and visit `localhost:3838/app` to view the application.

## Test Running the Image

Running this image won't start shiny server because it has no `ENTRYPOINT` or `CMD` as it was intended to be imported for use in other images. To test that it is working, run a container with `docker run --rm -p 3838:3838 colebrokamp/shiny bash -c "exec shiny-server"` and visit `localhost:38383` in your browser.

## Deploying to Server

These instructions are mainly aimed at my personal use for deploying to an internal server with some strict proxy access rules.

### Send Image to Server

Once the docker shiny app is built locally, transfer the image to the server via SSH, bzipping the content on the fly:

`docker save <image> | bzip2 | pv | ssh cchmc_geocore_dev 'bunzip | docker load'`

(protip: use `pv -s <estimated size>` to get ETA and percent progress, but how to estimate size of compressed image??)

### Run Image on server

Run the image, using the current system proxy variables so that R can use them inside the container too. (To export proxy variables, run `. ./proxy.sh` on the server.)

`docker run -d --name <NAME> -p 8080:3838 -e http_proxy-e https_proxy <IMAGE-ID>`

The image will be available at `<URL>:8080/app`.

To test it without public access, use `ssh -N -L localhost:3838:localhost:8080 cchmc_geocore_dev` to map port 8080 on the server to local port 3838. Then app will be available at `localhost:3838/<app_folder>`

### Automated Deployment Script

Use [docker_shiny_push.sh](docker_shiny_push.sh) to automate the entire process:

- make Dockerfile
- copy custom `shiny-server.conf` file
- make app name based on name of current folder
- build the image as `cole/<app-folder>:latest`
- save the docker image and pipe it to the remote server with a progress bar
- run image on an unused port after exporting `http_proxy` variables
- return image, container, and port information
- remove local image and cleanup
