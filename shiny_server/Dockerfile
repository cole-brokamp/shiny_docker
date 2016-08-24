FROM ubuntu:14.04

MAINTAINER "Cole Brokamp" cole.brokamp@gmail.com

# set user
RUN useradd docker \
  && mkdir /home/docker \
  && chown docker:docker /home/docker \
  && addgroup docker staff

RUN apt-get update && apt-get install -y \
    gdebi-core \
    pandoc pandoc-citeproc \
    libproj-dev libgdal-dev \
    libxml2-dev libxt-dev libcairo2-dev \
    libssh2-1-dev libcurl4-openssl-dev \
    curl less git make wget screen nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install R
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install r-base-core -y --force-yes \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set default CRAN repo and DL method
RUN echo 'options(repos=c(CRAN = "https://cran.rstudio.com/"), download.file.method="wget")' >> /etc/R/Rprofile.site

# install R packages
RUN sudo su - -c "R -e \"install.packages(c('devtools','shiny','rmarkdown','pacman'))\"" \
  && sudo su - -c "R -e \"devtools::install_github('cole-brokamp/CB')\"" \
  && sudo su - -c "R -e \"devtools::install_github('cole-brokamp/automagic')\"" \
  && sudo su - -c "R -e \"devtools::install_github('hoxo-m/githubinstall')\""

# Download and install latest version of shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

## install geo libraries and r packages
RUN wget -O - https://raw.githubusercontent.com/cole-brokamp/bash_setup/master/install_geos_gdal_proj4_for_linux.sh | bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sudo su - -c "R -e \"install.packages(c('rgeos','rgdal'))\""

# expose port to access app
EXPOSE 3838

# give docker user permission to write to logs
RUN chown docker /var/log/shiny-server
