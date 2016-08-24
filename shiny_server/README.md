# Docker Shiny Server Image

To dockerize your R Shiny application, the `colebrokamp/shiny` docker image must be available. This image serves as a starting point and reduces redundant rebuilds everytime a dockerfile is built for a new shiny app. This image will automatically be pulled from DockerHub if you build your own image from a Dockerfile that includes `from colebrokamp/shiny:latest`. If this is the case, you can skip how to build locally or pull from DockerHub with no problems. These instructions are aimed at users who wish to customize the `colebrokamp/shiny` docker image.

## Image Contents

In addition to R and Shiny Server, this image contains the R packages `devtools`, `pacman`, and `hoxo-m/githubinstall` for installing required R packages; `shiny` and `rmarkdown` to run shiny server; my custom R package (`github.com/cole-brokamp/CB`); and the geospatial R packages `rgeos` and `rgdal` (including the `gdal`, `geos`, and `proj4` software libraries). `cole-brokamp/automagic` is also included for automatic installation of required R packages.

## Building

**Build locally:**
The `Dockerfile` inside the `shiny_server` folder will create a docker image with R Shiny Server (including some geospatial packages). To build the image locally, use `docker build -t colebrokamp/shiny ./shiny_server`. Commiting any changes to this file on the GitHub repo will trigger a rebuild of the image on DockerHub.

**Pull from DockerHub:**
Alternatively, pull the image from DockerHub: `docker pull colebrokamp/shiny`.

## Test Running the Image

Running this image won't start shiny server because it has no `ENTRYPOINT` or `CMD` as it was intended to be imported for use in other images. To test that it is working, run a container with `docker run --rm -p 3838:3838 cole/shiny bash -c "exec shiny-server"` and visit `localhost:38383` in your browser.

*Note*: Although this will not run in detached mode, it will delete the container after it is killed. (Substitute `-d` for `--rm` to run the container in the background, although it will persist and have to be forcefully deleted if you wish to do so.)
