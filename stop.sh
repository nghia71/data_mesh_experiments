#!/bin/bash

echo "Stopping all services ...";

source .env;
NUMER_OF_KAFKA_INSTANCES=$(set | grep KRAFT_._ID | wc -l)
i=1
while [[ $i -le $NUMER_OF_KAFKA_INSTANCES ]]
do
    KRAFT_CONTAINER_NAME_VAR="KRAFT_${i}_CONTAINER_NAME"
    KRAFT_CONTAINER_NAME="${!KRAFT_CONTAINER_NAME_VAR}";
    docker exec ${KRAFT_CONTAINER_NAME} bash -c "chmod -R a+rw /tmp/server /var/lib/kafka/data"

    ((i = i + 1))
done

CURRENT_UID=$(id -u):$(id -g) docker compose down
echo "All services are stopped ✅";
