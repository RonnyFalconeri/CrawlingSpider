# CrawlingSpider
A simple web crawler inside a docker container using Apache Nutch 1. The idea of this project is to enable a quick setup of Apache Nutch with an integrated Solr instance by just starting a docker container. The friendly CrawlingSpider shall help you getting started in the world of web cawling and web scraping.

How does it work? You have to provide the Apache Nutch and Solr binary distribution. On startup, these will be loaded and installed into the container. After a few adjustments, the crawling service can be used.

Keep in mind that there are two versions of Apache Nutch available: _Nutch 1.X_ and _Nutch 2.X_. While version 1.X relies on Hadoop and is more suitable for production environments, version 2.X has more features and a different, more modern architecture. Both differentiate in execution and installation. Read [here](https://cwiki.apache.org/confluence/display/NUTCH/Home) for more informations about the difference between the two versions.


Used versions: **Nutch 1.17** & 
**Solr 8.5.1**

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
Newer version are not guaranteed to work. However, the current version of this project is only compatible with v8.5.1. Newer releases can be downloaded [here](https://www.apache.org/dyn/closer.cgi/lucene/solr/). If you want to download version 8.5.1, you have to download it from the [archive](https://archive.apache.org/dist/lucene/solr/). Remember: Download the binary - not the source code! Put the binary in the _/solr_ directory.


The project structure should look like this:

    /CrawlingSpider
        /nutch
            apache-nutch-*-bin.tar.gz
            nutch-site.xml
            seed.txt
        /solr
            solr-*.tgz
            schema.xml
        Dockerfile
        ...

### QUICK START
If you wasted too much time and must satisfy your boss as soon as possible, stop reading and just run these commands to setup Nutch and Solr in a container and execute your first crawl:
```bash
# build docker image
docker build -t crawling_spider .

# run container from image
docker run -d -it -p 8983:8983 --name crawler crawling_spider

# access container
docker exec -it crawler /bin/bash

# start solr server
solr-8.5.1/bin/solr start -force

# create nutch core in solr
solr-8.5.1/bin/solr create -c nutch -d solr-8.5.1/server/solr/configsets/nutch/conf/ -force

# set JAVA_HOME variable and forget about it
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

# enter nutch directory
cd apache-nutch-1.17

# start crawling with 2 iterations - it takes a few minutes
# increase iterations to earn yourself a nice coffee break
bin/crawl -i -s urls crawl 2
```
Execute query at <http://localhost:8983/solr/#/nutch/query> to print some results from the crawl.



## Start crawling!
There are two ways to crawl with Nutch. On the one hand you can execute every single command manually step by step for more control over the process (recommended for beginners) and on the other hand you can run one single command using a crawl script to automate the crawling process. To execute the following commands, enter the apache-nutch directory. Read the official tutorial [here](https://cwiki.apache.org/confluence/display/NUTCH/NutchTutorial#NutchTutorial-UsingIndividualCommandsforWhole-WebCrawling) for more informations.

First of all run:
```bash
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
```

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

Start indexing with Solr:
```bash
bin/nutch index crawl/crawldb/ -dir crawl/segments -linkdb crawl/linkdb/
```


### Crawl script
If you want to use the crawl script, use _bin/crawl_ instead of _bin/nutch_. This could take a few minutes.

Example:
```bash
bin/crawl -i -s urls crawl 2
```

This will automatically run all of the previous steps including the deduplication step.

Read [here](https://cwiki.apache.org/confluence/display/NUTCH/NutchTutorial#NutchTutorial-Usingthecrawlscript) to learn more.


## Export URLs
You can export the URLs from the crawl database with the dump command. The following command exports the urls into a folder named dump/ inside the crawl/ directory:
```bash
bin/nutch dump -segment crawl/segments -outputDir crawl/dump/
```

If you want to copy the dumped urls outside the container into a folder on your host machine, you can do that with the docker cp command.

If you still are inside the container, simply exit the container with:
```bash
exit
```

Copy the dump folder into a crawldump/ folder in your current directory:
```bash
docker cp crawler:apache-nutch-1.17/crawl/dump ./crawldump
```

Inside the crawldump/ folder you will find multiple folders like a8/ 89/ and so on. They contain the html source code of a specific url. You will also find a .json file. Each .json file corresponds to an iteration of your crawl execution e.g. if you crawled with 3 iterations, there will be 3 .json files. They contain the urls which were found in the given iteration.

You can use the dumped urls or its source code to process it with a scraper like selenium.