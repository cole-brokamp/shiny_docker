# shiny_docker

> A robust method to automatically dockerize your R Shiny Application

## Dockerizing Your Shiny Application

Using this method, every shiny docker image is built from the same Dockerfile in the `shiny_docker` github repository. The working directory from where `docker build ...` is called is assumed to be the folder containing the R Shiny application and all content is copied to `/srv/shiny-server/<app_folder>` where `<app_folder>` is defined using a `--build-arg`. 

The Dockerfile uses `colebrokamp/shiny` as a starting image and will be automatically pulled the first time that you build an image using this method. See the documentation accompanying the image on [DockerHub](https://hub.docker.com/r/colebrokamp/shiny/) for more details.

### Example

This example builds a docker image for the shiny app in the directory `hello_shiny`. Make sure to clone the repository so the application folder and docker resources are available if you want to try the example yourself.

```
git clone https://github.com/cole-brokamp/shiny_docker
cd shiny_docker/hello_shiny
docker build --build-arg app_folder=hello_shiny -t cole/hello_shiny .
```

Behind the scenes, the `automagic` R package scans the code inside the directory for necessary packages and installs them when building the Docker image so that no other customization should be necessary.

To run the app, use `docker run -d -p 3838:3838 cole/hello_shiny` and open `localhost:3838/hello_shiny`. Use `--rm` instead of `-d` if you would like the container to run in the foreground and be removed after it is stopped.

### Use With Your Own Shiny App

Make sure that the current working directory is your shiny application folder. Copy the Dockerfile from this repo to the current working directory (`wget https://raw.githubusercontent.com/cole-brokamp/shiny_docker/master/Dockerfile -q -O ./Dockerfile`).  Build and run as in the above example, replacing `hello_shiny` with the desired name of your app. Supplying the build arg `--build-arg app_folder=<app-folder>` will copy the contents of the working directory (i.e. everything needed for the Shiny app) to `/srv/shiny-server/<app-folder>` and automatically be served.

#### Shiny Configuration File

By default, a simple `shiny-server.conf` is downloaded from this github repository (`example_shiny-server.conf`) and copied to `/etc/shiny-server/shiny-server.conf`. To use a custom configuration file, include a file in the app directory called `shiny-server.conf`. If this file is present, it will be copied to `/etc/shiny-server/shiny-server.conf` instead of downloading and using the example configuration file. See more details on server configuration [here](http://docs.rstudio.com/shiny-server/#server-management).

#### Build Args

Besides the required `app_folder` argument, other `--build-args` [are available](https://docs.docker.com/engine/reference/builder/#/arg) as predefined arguments in all docker builds. For example, to call the build with a proxy:

```
docker build \
    --build-arg app_name=hello_shiny \
    --build-arg http_proxy=<PROXY-URL> \
    -t colebrokamp/hello_shiny .
```

Note that Docker *requires* a default value for any build args so not supplying `app_name` will cause the build to fail. However, predefined build args, like `http_proxy` and `https_proxy`, are not required and do not have default values.

## Deploying to Server

These instructions are mainly aimed at my personal use for deploying to an internal server with some strict proxy access rules.

### Send Image to Server

Once the docker shiny app is built locally, transfer the image to the server via SSH, bzipping the content on the fly:

`docker save <image> | bzip2 | pv | ssh cchmc_geocore_dev 'bunzip | docker load'`

(protip: use `pv -s <estimated size>` to get ETA and percent progress, but how to estimate size of compressed image??)

### Run Image on server

Run the image, using the current system proxy variables so that R can use them inside the container too. (To export proxy variables, run `. ./proxy.sh` on the server.

`docker run -d --name <NAME> -p 8080:3838 -e http_proxy-e https_proxy <IMAGE-ID>`

The image will be available at `<URL>:8080/<app_folder>`. 

To test it without public access, use `ssh -N -L localhost:3838:localhost:8080 cchmc_geocore_dev` to map port 8080 on the server to local port 3838. Then app will be available at `localhost:3838/<app_folder>`
