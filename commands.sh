#!/bin/bash
#echo "STARTING CRAWLER"
echo "STARTING CRAWLER  /╲/\╭( ͡° ͡° ͜ʖ ͡° ͡°)╮/\╱\ "

# open nutch folder
cd apache-nutch-1.17

# set JAVA_HOME
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

# start crawling seeds
bin/nutch inject crawl/crawldb urls

# generate list of pages to be fetched from seeds
# store path to segment in variable
s1=$(bin/nutch generate crawl/crawldb crawl/segments | grep segment: | sed 's/^.*: //')

echo $s1

# start fetching
bin/nutch fetch $s1

# parse fetched entries
bin/nutch parse $s1

# update database
bin/nutch updatedb crawl/crawldb $s1

# prepare updated database for indexing invert links (e.g. with Apache SOLR)
bin/nutch invertlinks crawl/linkdb -dir crawl/segments