FROM colebrokamp/shiny:latest

MAINTAINER "Cole Brokamp" cole.brokamp@gmail.com

# build args
ARG app_folder=${PWD##*/}

# copy app contents to app_folder
RUN mkdir /srv/shiny-server/$app_folder
COPY * /srv/shiny-server/$app_folder

# copy config file if it exists
RUN if [ -f /srv/shiny-server/$app_folder/shiny-server.conf ]; then (>&2 echo "Using config file inside app directory") && cp /srv/shiny-server/$app_folder/shiny-server.conf /etc/shiny-server/shiny-server.conf; fi

# if it doesn't exist, download and copy the example config file
RUN if [ ! -f /srv/shiny-server/$app_folder/shiny-server.conf ]; then (>&2 echo "Config file inside app directory not found; downloading example config file") && wget https://raw.githubusercontent.com/cole-brokamp/shiny_docker/master/example_shiny-server.conf -q -O /etc/shiny-server/shiny-server.conf; fi

# install necessary R packages
RUN sudo su - -c "R -e \"setwd('/srv/shiny-server/$app_folder'); automagic::automagic()\""

# start it
CMD exec shiny-server >> /var/log/shiny-server.log 2>&1
