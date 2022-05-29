#!/bin/bash
#clean up old files
rm -f master.tar.gz
rm -f dev.tar.gz
rm -rf berkeleylab-metabat-*

#stable release version
wget https://bitbucket.org/berkeleylab/metabat/get/master.tar.gz
tar xzvf master.tar.gz
cd berkeleylab-metabat-*

#latest development version
wget https://bitbucket.org/berkeleylab/metabat/get/dev.tar.gz
tar xzvf dev.tar.gz
cd berkeleylab-metabat-*

#run the installation script
mkdir build && cd build && cmake .. [ -DCMAKE_INSTALL_PREFIX=/path/to/install ] && make && make test && make install
