from colebrokamp/shiny:latest

MAINTAINER "Cole Brokamp" cole.brokamp@gmail.com

# build args
ARG app_folder
ARG config_file=example_shiny-server.conf

# copy config file
COPY $config_file /etc/shiny-server/shiny-server.conf
# copy app
COPY $app_folder /srv/shiny-server/$app_name

# install necessary R packages
RUN cd /srv/shiny-server/$app_name && sudo su - -c "R -e \"automagic::automagic()\""

# start it
CMD exec shiny-server >> /var/log/shiny-server.log 2>&1
