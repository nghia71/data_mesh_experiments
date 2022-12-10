#!/bin/bash

if [ -z "$(ls -f .env)" ]; then
    echo "Please run ./setup.sh";
fi

echo "Start all services ...";
CURRENT_UID=$(id -u):$(id -g) docker compose up -d

echo "Wait for all services to be ready ...";
source .env;
NUMBER_OF_KAFKA_INSTANCES=$(set | grep KRAFT_._ID | wc -l)
i=1
while [[ $i -le $NUMBER_OF_KAFKA_INSTANCES ]]
do
    KRAFT_CONTAINER_NAME_VAR="KRAFT_${i}_CONTAINER_NAME"
    KRAFT_CONTAINER_NAME="${!KRAFT_CONTAINER_NAME_VAR}";
    KRAFT_EXTERNAL_PORT_VAR="KRAFT_${i}_EXTERNAL_PORT"
    KRAFT_HOST="${CLUSTER_IP}:${!KRAFT_EXTERNAL_PORT_VAR}"

    echo "Wait for ${KRAFT_CONTAINER_NAME} ...";
    ./wait-for-it.sh ${KRAFT_HOST};
    echo "${KRAFT_CONTAINER_NAME} is ready ✅";

    ((i = i + 1))
done

echo "Wait for ${KAFKA_CONNECT_STANDALONE} ...";
./wait-for-it.sh ${CLUSTER_IP}:${KAFKA_CONNECT_PORT};
echo "${KAFKA_CONNECT_STANDALONE} is ready ✅";
