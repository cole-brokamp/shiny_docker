# shiny_docker

> A robust method to automatically dockerize your R Shiny Application

## Dockerizing Your Shiny Application

Using this method, every shiny docker image is built from the same Dockerfile in the `shiny_docker` github repository. Application specific code is copied to the image using a build argument. The Dockerfile uses `colebrokamp/shiny` as a starting image and will be automatically pulled the first time that you build an image using this method. See the documentation accompanying the image on [DockerHub](https://hub.docker.com/r/colebrokamp/shiny/) for more details.

### Example

This example builds a docker image for the shiny app in the directory `hello_shiny`. Make sure to clone the repository so the application folder and docker resources are available if you want to try the example yourself.

```
docker build --build-arg app_folder=hello_shiny -t cole/hello_shiny .
```

Behind the scenes, the docker daemon copies the app directory to `/srv/shiny-server/` and the `automagic` R package scans the code inside the directory for necessary packages and installs them.

To run the app, use `docker run -d -p 3838:3838 cole/hello_shiny` and open `localhost:3838/hello_shiny`. Use `--rm` instead of `-d` if you would like the container to run in the foreground and be removed after it is stopped.

### Use With Your Own Shiny App

Make sure that the shiny application folder is in your current working directory. Copy the Dockerfile from this repo to the current working directory.  Build and run as in the above example, replacing `hello_shiny` with the name of your app folder. Supplying the build arg `--build-arg app_folder=<app-folder>` will copy `<app-folder>` to `/srv/shiny-server` and automatically be served.

Alternatively, change your working directory to inside the shiny application folder. Copy the Dockerfile here and build with `docker build --build-arg app_folder=$PWD -t cole/<app-name> .` This will copy the current working directory to the image.

#### Shiny Configuration File

By default, a simple `shiny-server.conf` is downloaded from this github repository (`example_shiny-server.conf`) and copied to `/etc/shiny-server/shiny-server.conf`. To use a custom configuration file, include a file in the app directory called `shiny-server.conf`. If this file is present, it will be copied to `/etc/shiny-server/shiny-server.conf` instead of downloading and using the example configuration file. See more details on server configuration [here](http://docs.rstudio.com/shiny-server/#server-management).

#### Build Args

Besides the required `app_folder` argument, other `--build-args` [are available](https://docs.docker.com/engine/reference/builder/#/arg) as predefined arguments in all docker builds. For example, to call the build with a proxy:

```
docker build \
    --build-arg app_name=hello_shiny \
    --build-arg http_proxy=http://srv-sysproxy:ieQu3nei@bmiproxyp.chmcres.cchmc.org:80 \
    --build-arg https_proxy=https://srv-sysproxy:ieQu3nei@bmiproxyp.chmcres.cchmc.org:80 \
    -t colebrokamp/hello_shiny .
```

Note that Docker *requires* a default value for any build args so not supplying `app_name` will cause the build to fail. However, predefined build args, like `http_proxy` and `https_proxy`, are not required and do not have default values.

## Deploying to Server

For even further automation, use a bash script for automatic deployment with building done on the server side.

```
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [[ $# < 1 ]]; then
        echo "copies shiny app inside the current folder to server"
        echo "dockerizes, builds, and runs"
        echo "usage: docker_shiny_push"
        exit 0
fi

af=`basename $PWD`
scp -r $PWD <server>:~
ssh -q -T <server> > /dev/null << HERE
      cd ~/$af
      wget https://raw.githubusercontent.com/cole-brokamp/shiny_docker/master/Dockerfile -q -O ./Dockerfile
      docker build --build-arg app_folder=$PWD -t cole/$af .
      docker run -d -p 3838:3838 cole/$af
HERE

echo "dockerized shiny app is now running"

```
