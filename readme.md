# CrawlingSpider
A simple web crawler inside a docker container using Apache Nutch 1. The idea of this project is to enable a quick setup of Apache Nutch with an integrated Solr instance by just starting a docker container. The friendly CrawlingSpider shall help you getting started in the world of web cawling and web scraping.

How does it work? You have to provide the Apache Nutch and Solr binary distribution. On startup, these will be loaded and installed into the container. After a few adjustments, the crawling service can be used.

Keep in mind that there are two versions of Apache Nutch available: _Nutch 1.X_ and _Nutch 2.X_. While version 1.X relies on Hadoop and is more suitable for production environments, version 2.X has more features and a different, more modern architecture. Both differentiate in execution and installation. Read [here](https://cwiki.apache.org/confluence/display/NUTCH/Home) for more informations about the difference between the two versions.


## Getting Started

### Preparations

#### Apache Nutch
Download the Apache Nutch binary distribution [here](https://www.apache.org/dyn/closer.cgi/nutch/) (currently only compatible with v1.17) and put it in the _/nutch_ directory of the project.


The following configuration files are already provided by default:

    - index-writers.xml
    - nutch-site.xml
    - seed.txt

You may edit them. Here you can set custom configurations (nutch-site.xml) and seed URLs (seed.txt). The file _index-writers.xml_ is needed in order for Nutch to point to the Solr instance.

NutchTutorial - [Here](https://cwiki.apache.org/confluence/display/NUTCH/NutchTutorial) you can find further information about the installation and setup of Apache Nutch and integration of Solr.


#### Apache SOLR
According to the _NutchTutorial_, you have to use _Solr 8.5.1_ with _Nutch 1.17_.
Newer version are not guaranteed to work. Newer releases can be downloaded [here](https://www.apache.org/dyn/closer.cgi/lucene/solr/). If you want to download version 8.5.1, you have to download it from the [archive](https://archive.apache.org/dist/lucene/solr/). Remember: Download the binary - not the source code! Put the binary in the _/solr_ directory.


The project structure should look like this:

    /CrawlingSpider
        /nutch
            apache-nutch-*-bin.tar.gz
            index-writers.xml
            nutch-site.xml
            seed.txt
        /solr
            solr-*.tgz
            schema.xml
        Dockerfile
        docker-compose.yml
        ...

### Start Docker Container
After you met als preparations you can setup the Docker Container. Build the Docker image with the Dockerfile:
```bash
docker built -t crawling_spider .
```

To start a container from the image run:
```bash
docker run -d -it -p 8983:8983 --name crawler crawling_spider
```

After that the container will run in detached mode (in the background). Now you have a running instance of Nutch and Solr. To access the container you have to run:
```bash
docker exec -it crawler /bin/bash
```


## Before you crawl
Before you can start crawling with Nutch and use the Solr web UI, you have to start Solr and create a nutch core within Solr.

Enter the Solr directory and run this command to start Solr:
```bash
bin/solr start -force
```

Now create a nutch core:
```bash
bin/solr create -c nutch -d solr-8.5.1/server/solr/configsets/nutch/conf/ -force
```

You should now be able to open the Solr web UI in the browser. If the container runs on your local machine, open the site on port 8983 with <http://localhost:8983>.



## Start crawling!
There are two ways to crawl with Nutch. On the one hand you can execute every single command manually step by step for more control over the process (recommended for beginners) and on the other hand you can run one single command using a crawl script to automate the crawling process. To execute the following commands, enter the apache-nutch directory. Read the official tutorial [here](https://cwiki.apache.org/confluence/display/NUTCH/NutchTutorial#NutchTutorial-UsingIndividualCommandsforWhole-WebCrawling) for more informations.

### Step by Step
The crawling process consists of the following steps:

    1. Generate segments from database
    2. Fetch segment
    3. Parse segment
    4. Update results to database
    5. Invert links for the indexing process

Before you can generate a segment, you have to inject the seed URLs provided by _nutch/seed.txt_.
```bash
bin/nutch inject crawl/crawldb urls
```

Generate segment to fetch
```bash
bin/nutch generate crawl/crawldb crawl/segments
```

Save the name of the segment in the shell variable s1
```bash
s1=`ls -d crawl/segments/2* | tail -1`
```

You can see the name of the segment by printing s1 with echo
```bash
echo $s1
```

Fetch the segment
```bash
bin/nutch fetch $s1
```

Parse the segment
```bash
bin/nutch parse $s1
```

Update results
```bash
bin/nutch updatedb crawl/crawldb $s1
```


Congratulations! You have now crawled for the first time.
If you want, crawl a second time. This can take a few minutes:
```bash
bin/nutch generate crawl/crawldb crawl/segments -topN 100
s2=`ls -d crawl/segments/2* | tail -1`
echo $s2

bin/nutch fetch $s2
bin/nutch parse $s2
bin/nutch updatedb crawl/crawldb $s2
```


If you are absolutely crazy, crawl a third time:
```bash
bin/nutch generate crawl/crawldb crawl/segments -topN 100
s3=`ls -d crawl/segments/2* | tail -1`
echo $s3

bin/nutch fetch $s3
bin/nutch parse $s3
bin/nutch updatedb crawl/crawldb $s3
```

You should now have enough links to process. Before you can use them with Solr, you have to invert the links first:
```bash
bin/nutch invertlinks crawl/linkdb -dir crawl/segments
```

### Crawl script
If you want to use the crawl script, use _bin/crawl_ instead of _bin/nutch_.

Example:
```bash
bin/crawl crawl/crawldb 3
```

Read [here](https://cwiki.apache.org/confluence/display/NUTCH/NutchTutorial#NutchTutorial-Usingthecrawlscript) to learn more.
