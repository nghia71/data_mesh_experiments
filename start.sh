#!/bin/bash

if [ -z "$(ls -f .env)" ]; then
    echo "Please run ./setup.sh";
fi

echo "Start all services ...";
CURRENT_UID=$(id -u):$(id -g) docker compose up -d

echo "Wait for all services to be ready ...";
source .env;
NUMER_OF_KAFKA_INSTANCES=$(set | grep KRAFT_._ID | wc -l)
i=1
while [[ $i -le $NUMER_OF_KAFKA_INSTANCES ]]
do
    KRAFT_CONTAINER_NAME_VAR="KRAFT_${i}_CONTAINER_NAME"
    KRAFT_CONTAINER_NAME="${!KRAFT_CONTAINER_NAME_VAR}";
    KRAFT_HOST_NAME_VAR="KRAFT_${i}_HOST_NAME"
    KRAFT_BROKER_PORT_VAR="KRAFT_${i}_BROKER_PORT"
    KRAFT_HOST="${!KRAFT_HOST_NAME_VAR}:${!KRAFT_BROKER_PORT_VAR}"

    echo "Wait for ${KRAFT_CONTAINER_NAME} ...";
    ./kafka/wait-for-it.sh ${KRAFT_HOST};
    echo "${KRAFT_CONTAINER_NAME} is ready ✅";

    ((i = i + 1))
done

# if [ -z $KRAFT_CREATE_TOPICS ]; then
#     echo "No topic requested for creation ✅";
# else
#     pc=1
#     if [ $KRAFT_PARTITIONS_PER_TOPIC ]; then
#         pc=$KRAFT_PARTITIONS_PER_TOPIC
#     fi

#     for i in $(echo $KRAFT_CREATE_TOPICS | sed "s/,/ /g")
#     do
#         ./bin/kafka-topics.sh --create --topic "$i" --partitions "$pc" --replication-factor 1 --bootstrap-server $kafka_addr;
#     done
#     echo "Requested topics ${KRAFT_CREATE_TOPICS} created ✅";
# fi

