## on a mac?  use `brew install gdal` instead!

# update system
sudo apt-get update && sudo apt-get upgrade

# install prerequisites
sudo apt-get install -y \
  build-essential \
  flex make bison gcc libgcc1 g++ cmake ccache \
  python python-dev \
  python-opengl \
  python-wxversion python-wxtools python-wxgtk2.8 \
  python-dateutil libgsl0-dev python-numpy \
  wx2.8-headers wx-common libwxgtk2.8-dev libwxgtk2.8-dbg \
  libwxbase2.8-dev  libwxbase2.8-dbg \
  libncurses5-dev \
  zlib1g-dev gettext \
  libtiff-dev libpnglite-dev \
  libcairo2 libcairo2-dev \
  sqlite3 libsqlite3-dev \
  libpq-dev \
  libreadline6 libreadline6-dev libfreetype6-dev \
  libfftw3-3 libfftw3-dev \
  libboost-thread-dev libboost-program-options-dev liblas-c-dev \
  resolvconf \
  libjasper-dev \
  subversion \
  libav-tools libavutil-dev ffmpeg2theora \
  libffmpegthumbnailer-dev \
  libavcodec-dev \
  libxmu-dev \
  libavformat-dev libswscale-dev \
  checkinstall \
  libglu1-mesa-dev libxmu-dev \
  ghostscript

# Compile/install GEOS. Taken from:
# http://grasswiki.osgeo.org/wiki/Compile_and_Install_Ubuntu#GEOS_2

cd /tmp
wget http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
bunzip2 geos-3.4.2.tar.bz2
tar xvf  geos-3.4.2.tar

cd geos-3.4.2

./configure  &&  make  &&  sudo make install
sudo ldconfig

##########################################

# Compile & install proj.4. Taken from:
# http://grasswiki.osgeo.org/wiki/Compile_and_Install_Ubuntu#PROJ4

sudo apt-get install -y subversion

cd /tmp
svn co http://svn.osgeo.org/metacrs/proj/branches/4.8/proj/

cd /tmp/proj/nad
sudo wget http://download.osgeo.org/proj/proj-datumgrid-1.5.zip

unzip -o -q proj-datumgrid-1.5.zip

#make distclean

cd /tmp/proj/

./configure  &&  make  &&  sudo make install && sudo ldconfig

##########################################

# install gdal 1.10.1 - must happen after proj & geos
# taken from:
# http://grasswiki.osgeo.org/wiki/Compile_and_Install_Ubuntu#GDAL

# sudo apt-get install libtiff4

cd /tmp
svn co https://svn.osgeo.org/gdal/branches/1.10/gdal gdal_stable
cd gdal_stable
#make distclean
CFLAGS="-g -Wall" LDFLAGS="-s" ./configure \
--with-png=internal \
--with-libtiff=internal \
--with-geotiff=internal \
--with-jpeg=internal \
--with-gif=internal \
--with-ecw=no \
--with-expat=yes \
--with-sqlite3=yes \
--with-geos=yes \
--with-python \
--with-libz=internal \
--with-netcdf \
--with-threads=yes \
--without-grass  \
--without-ogdi \
--with-xerces=yes

#with-pg=/usr/bin/pg_config \

make -j2  &&  sudo make install  &&  sudo ldconfig

apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
