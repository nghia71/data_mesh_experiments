#!/bin/bash

source .env

echo "Create ${KRAFT_TEST_TOPIC} ...";
docker exec --user $(id -u):$(id -g) ${KRAFT_1_CONTAINER_NAME} ./bin/kafka-topics.sh \
    --create --topic ${KRAFT_TEST_TOPIC} \
    --partitions ${KRAFT_TEST_PARTITIONS} \
    --replication-factor ${KRAFT_TEST_REPLICATION_FACTOR} \
    --bootstrap-server ${LOCAL_IP}:${KRAFT_1_EXTERNAL_PORT};
echo "${KRAFT_TEST_TOPIC} created ✅";


echo $'12345\nabcde\n@$#^%$' > sent_messages.txt
NO_MESSAGES="$(cat sent_messages.txt | wc -l)"

echo "Sending ${NO_MESSAGES} messages into ${KRAFT_TEST_TOPIC} ...";
docker exec --interactive --tty ${KRAFT_1_CONTAINER_NAME} ./bin/kafka-console-producer.sh \
    --topic ${KRAFT_TEST_TOPIC} \
    --bootstrap-server ${LOCAL_IP}:${KRAFT_1_EXTERNAL_PORT} < sent_messages.txt;
echo "${NO_MESSAGES} messages sent ✅";

echo "Receiving ${NO_MESSAGES} messages from ${KRAFT_TEST_TOPIC} ...";
docker exec --interactive --tty ${KRAFT_1_CONTAINER_NAME} ./bin/kafka-console-consumer.sh \
    --topic ${KRAFT_TEST_TOPIC} \
    --max-messages ${NO_MESSAGES} \
    --bootstrap-server ${LOCAL_IP}:${KRAFT_1_EXTERNAL_PORT} > recv_messages.txt;
NO_MESSAGES="$(cat recv_messages.txt | wc -l)"
echo "Received ${NO_MESSAGES} messages ✅";

DIFF="$(diff sent_messages.txt recv_messages.txt)";
if [ -z $DIFF ]; then
    echo "All ${NO_MESSAGES} messages matched ✅";
    rm sent_messages.txt recv_messages.txt

    echo "Deleting ${KRAFT_TEST_TOPIC} ...";
    docker exec --user $(id -u):$(id -g) ${KRAFT_1_CONTAINER_NAME} ./bin/kafka-topics.sh \
        --delete --topic ${KRAFT_TEST_TOPIC} \
        --bootstrap-server ${LOCAL_IP}:${KRAFT_1_EXTERNAL_PORT};
    echo "${KRAFT_TEST_TOPIC} deleted ✅";
else
    echo "ERROR: sent and received messages do not match.";
fi