#!/bin/sh

# export $(grep -v '^#' .env | xargs)

echo "Start all services ...";
if [ -z $1 ]; then
    docker compose up
else
    docker compose up
    # docker compose up -d

    # for i in {1..2}
    # do
    #     KRAFT_CONTAINER_NAME="KRAFT_${i}_CONTAINER_NAME"
    #     KRAFT_HOST="RAFT_${i}_HOST_NAME:$KRAFT_${i}_BROKER_PORT"
    #     echo "Wait for ${KRAFT_CONTAINER_NAME} ...";
    #     ./kafka/wait-for-it.sh ${KRAFT_HOST};
    #     echo "${KRAFT_CONTAINER_NAME} is ready ✅";
    # done
    # echo "All services are ready ✅";
fi


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

