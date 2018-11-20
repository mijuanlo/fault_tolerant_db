#!/bin/bash

SLEEPTIME=60
DETACHED=0

abort(){
    echo Exitting...
    exit 1
}

trap abort INT;

cd ../
echo "Stopping dockers..."
docker-compose down
if [[ $(docker ps -a -q) ]]; then
    names=$(docker ps -a -q --filter "name=consul-server" --filter "name=mrm" --filter "name=mysql-" --filter "name=proxysql")
    if [ -n "$names" ]; then
        echo "Removing containers..."
        docker rm -f ${names}
    fi
fi
echo "Starting docker compose..."
if [ "x${DETACHED}" = "x0" ];then
    docker-compose up &
else
    docker-compose up -d
fi
echo "Bootstraping MRM, waiting for MySQL instaces"
sleep ${SLEEPTIME}
docker exec -it mrm bash /docker-entrypoint-initdb.d/replication-bootstrap.sh
