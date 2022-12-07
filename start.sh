#!/bin/sh

echo "Start all services ...";
docker compose up -d

for i in {1..2} do
    echo "Wait for ${KRAFT_${i}_CONTAINER_NAME} ...";
    ./kafka/wait-for-it.sh $KRAFT_${i}_HOST_NAME:$KRAFT_${i}_BROKER_PORT;
    echo "${KRAFT_1_CONTAINER_NAME} is ready ✅";
done

echo "All services are ready ✅";

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

