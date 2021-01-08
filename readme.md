# CrawlingSpider
A simple web crawler inside a docker container using Apache Nutch 1. The idea of this project is to enable a quick setup of Apache Nutch by just starting a docker container. The friendly CrawlingSpider shall help you getting started in the world of web cawling and web scraping.

How does it work? You have to provide the Apache Nutch binary distribution and the follwoing configuration files: _nutch-site.xml_ and _seed.txt_. On startup, these will be loaded into the container and the service will do its job.


## Getting Started

### Preparations
Before you start the docker container you have to provide some important files:

Download the Apache Nutch binary distribution [here](https://www.apache.org/dyn/closer.cgi/nutch/) (currently only compatible with v1.17) and put it in the root directory of the project.


The configuration files _nutch-site.xml_ and _seed.txt_ are already provided by default. You may edit them. Here you can set custom configurations and seed URLs.

The project structure should look like this:

    /CrawlingSpider
        /apache-nutch-1.17-bin.tar.gz
        /nutch-site.xml
        /seed.txt
        /commands.sh
        ...

### Start Docker Container
After you met als preparations you can start the Docker Container. Just simply run:
```bash
docker docker-compose up
```


## Crawling Lifecycle
The crawler gets invoked by the bash commands in _commands.sh_. You may edit them to change the invoking behaviour.