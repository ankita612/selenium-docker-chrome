#!/usr/bin/env bash
#!/bin/bash

#docker rm $(docker ps -aq)
#sudo rm /var/lib/docker/network/files/local-kv.db

# $1 = profile in cucumber.yml
# $2 = test enviuronments
# $3 = browser
if [ $# -eq 0 ]
  then
    echo " "
    echo "Error: No test tags supplied. Please supply test tags. "
    echo " "
    echo "Example:"
    echo "  single tag    : @test"
    echo "  multiple tags : @test @stage"
    echo " "
    exit 0
fi


PROFILE=$1
SUT=$2
BROWSER=$3
# number of nodes that you would like to invoke in the test
export NUM_NODE=10

if [ "$(docker ps -q -f name=selenium-hub)" ]; then
    docker-compose stop selenium-hub
    echo "inside if"
fi
#docker-compose restart selenium-hub
echo "I am here"
docker-compose up -d
echo "new container"


docker exec selenium wait_all_done 30s
docker-compose  scale chrome=$NUM_NODE
docker logs selenium-hub


until [ "$(curl 'http://localhost:4444/grid/api/hub/status' | sed s/[{:}]//g | sed s/\"//g | awk -v k="text" '{split($1,a,","); print a[1]; print a[19]}' | sed 'N;s/\n//')" == "successtrueslotCountsfree$NUM_NODE" ]; do
    echo "free slots"
    curl 'http://localhost:4444/grid/api/hub/status' | sed s/[{:}]//g | sed s/\"//g | awk -v k="text" '{split($1,a,","); print a[1]; print a[19]}' | sed 'N;s/\n//'
    sleep 1
    echo "Wait for Selenium hub to load"
done
echo "All 10 slots are free now"


echo "scaled to 10 nodes"
bundle exec rake run_test_in_parallel \
PROFILE=$PROFILE \
SUT=$SUT \
BROWSER=$BROWSER

docker-compose stop selenium-hub