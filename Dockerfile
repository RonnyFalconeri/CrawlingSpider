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

# copy downloaded Nutch binary distribution into container
COPY apache-nutch-1.17-bin.tar.gz apache-nutch-1.17-bin.tar.gz

# untar the binary
RUN tar -xvzf apache-nutch-1.17-bin.tar.gz

# copy nutch config into container
COPY nutch-site.xml apache-nutch-1.17/conf/

# create url folder
RUN mkdir -p apache-nutch-1.17/urls

# copy seeds into container
COPY seed.txt apache-nutch-1.17/urls/



# ---------------------------
# START CRAWLER
# ---------------------------

# copy commands from commands.sh
COPY commands.sh /scripts/commands.sh
RUN chmod +x /scripts/commands.sh
ENTRYPOINT ["/scripts/commands.sh"]

