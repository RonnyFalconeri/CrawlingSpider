FROM ubuntu:latest

# ---------------------------
# INSTALL DEPENDENCIES
# ---------------------------

RUN apt-get update
RUN apt-get install -y default-jre
RUN apt-get install -y default-jdk


# ---------------------------
# COPY CONFIGS INTO CONTAINER
# ---------------------------

# setup Apache Nutch

# copy downloaded Nutch binary distribution into container
COPY nutch/apache-nutch-1.17-bin.tar.gz apache-nutch-1.17-bin.tar.gz

# untar the binary
RUN tar -xvzf apache-nutch-1.17-bin.tar.gz

# copy nutch config into container
COPY nutch/nutch-site.xml apache-nutch-1.17/conf/

# create url folder
RUN mkdir -p apache-nutch-1.17/urls

# copy seeds into container
COPY nutch/seed.txt apache-nutch-1.17/urls/

# copy index-writers into container to integrate solr
COPY nutch/index-writers.xml apache-nutch-1.17/conf/


# setup Apache SOLR

# copy downloaded SOLR binary into container
COPY solr/solr-8.5.1.tgz solr-8.5.1.tgz

# untar the binary
RUN tar -xvzf solr-8.5.1.tgz

# create resources for the SOLR core
RUN mkdir -p solr-8.5.1/server/solr/configsets/nutch/
RUN cp -r solr-8.5.1/server/solr/configsets/_default/* solr-8.5.1/server/solr/configsets/nutch/

# copy schema.xml into solr conf directory
COPY solr/schema.xml solr-8.5.1/server/solr/configsets/nutch/conf/

