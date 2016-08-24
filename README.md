# shiny_docker

> A robust method to automatically dockerize your R Shiny Application

## Dockerizing Your Shiny Application

Using this method, every shiny docker image is built from the same Dockerfile in the `shiny_docker` github repository. Application specific code and other customizations are achieved using using build arguments. This allows you to dockerize your shiny app without installing or downloading anything (other than Docker!) The Dockerfile uses `colebrokamp/shiny` as a starting image and will be automatically pulled the first time that you build an image using this method. See the [shiny_server README](shiny_server/README.md) for more details.

### Example

This example builds a docker image for the shiny app in the directory `hello_shiny`. Make sure to clone the repository so the application folder is available if you want to try the example yourself. We've also tagged the image as `cole/hello_shiny` to easily run it in the future.

```
docker build \
    --build-arg app_name=hello_shiny \
    -t cole/hello_shiny \
    https://github.com/cole-brokamp/shiny_docker
```
Behind the scenes, the docker daemon copies the app directory to `/srv/shiny-server/` and the `automagic` R package scans the code inside the directory for necessary packages and installs them.

To run the app, use `docker run -d -p 3838:3838 cole/hello_shiny` and open `localhost:3838/<app_name>`. Use `--rm` instead of `-d` if you would like the container to run in the foreground and be removed after it is stopped.

### Build Arguments

As in the above examples, supply any of the following build args with `--build-arg`. Possible build args are:

- `app_folder`
  - name of folder in the current working directory that contains the app files
  - will be copied to `/srv/shiny-server/`
- `config_file`
  - shiny config file to be copied to `/etc/shiny-server/shiny-server.conf`
  - use this file to add your own (see [here](http://docs.rstudio.com/shiny-server/#server-management) for more details)
- `http{s}_proxy`
  - supply a proxy if necessary
  - this option (and [others](https://docs.docker.com/engine/reference/builder/#/arg)) are predefined in all docker builds

Note that Docker *requires* a default value for any build args so not supplying `app_name` will cause the build to fail. The `http_proxy` and `https_proxy` are not required and do not have default values. `config-file` defaults to an example included in the github repository.

#### Example With All Build Args

```
docker build \
	--build-arg config_file=shiny-server.conf \
    --build-arg app_name=hello_shiny \
    --build-arg http_proxy=http://srv-sysproxy:ieQu3nei@bmiproxyp.chmcres.cchmc.org:80 \
    --build-arg https_proxy=https://srv-sysproxy:ieQu3nei@bmiproxyp.chmcres.cchmc.org:80 \
    -t colebrokamp/hello_shiny \
    https://github.com/cole-brokamp/shiny_docker
```
