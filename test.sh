#!/bin/bash

source .env

echo "Create ${KRAFT_TEST_TOPIC} ...";
docker exec ${KRAFT_1_CONTAINER_NAME} ./bin/kafka-topics.sh \
    --create --topic ${KRAFT_TEST_TOPIC} \
    --partitions ${KRAFT_TEST_PARTITIONS} \
    --replication-factor ${KRAFT_TEST_REPLICATION_FACTOR} \
    --bootstrap-server ${KRAFT_1_CONTAINER_NAME}:${KRAFT_1_EXTERNAL_PORT};
echo "${KRAFT_TEST_TOPIC} created ✅";

NO_MESSAGES=3;
seq ${NO_MESSAGES} > sent.txt;

echo "Sending ${NO_MESSAGES} messages into ${KRAFT_TEST_TOPIC} ...";
docker exec ${KRAFT_1_CONTAINER_NAME} \
    bash -c "seq ${NO_MESSAGES} | ./bin/kafka-console-producer.sh  --topic ${KRAFT_TEST_TOPIC}  --bootstrap-server ${KRAFT_2_CONTAINER_NAME}:${KRAFT_2_EXTERNAL_PORT}"
echo "${NO_MESSAGES} messages sent ✅";

echo "Receiving ${NO_MESSAGES} messages from ${KRAFT_TEST_TOPIC} ...";
docker exec ${KRAFT_1_CONTAINER_NAME} ./bin/kafka-console-consumer.sh \
    --topic ${KRAFT_TEST_TOPIC} \
    --from-beginning --max-messages ${NO_MESSAGES} \
    --bootstrap-server ${CLUSTER_IP}:${KRAFT_2_EXTERNAL_PORT} > recv.txt
echo "${NO_MESSAGES} messages received ✅";

if [ -z "$(diff recv.txt sent.txt)" ]; then
    echo 'Sent and receive messages matched  ✅'
else
    echo 'ERROR: Sent and receive messages did not match.'
fi

rm recv.txt sent.txt

echo "Deleting ${KRAFT_TEST_TOPIC} ...";
docker exec ${KRAFT_1_CONTAINER_NAME} ./bin/kafka-topics.sh \
    --delete --topic ${KRAFT_TEST_TOPIC} \
    --bootstrap-server ${CLUSTER_IP}:${KRAFT_1_EXTERNAL_PORT};
echo "${KRAFT_TEST_TOPIC} deleted ✅";

TEST_FILE=test.txt
TEST_MESSAGES="foo\nbar"
NO_MESSAGES=2

echo "Create test.txt file for connect-test topic with file-source connector ...";
docker exec ${KRAFT_1_CONTAINER_NAME} bash -c 'echo -e ${TEST_MESSAGES} > ${TEST_FILE}';
echo "${TEST_FILE} created ✅";

docker exec ${KRAFT_1_CONTAINER_NAME} ./bin/connect-standalone.sh \
    config/connect-standalone.properties \
    config/connect-file-source.properties \
    config/connect-file-sink.properties;

TEST_SINK_FILE=test.sink.txt
docker exec ${KRAFT_1_CONTAINER_NAME} bash -c 'cat ${TEST_SINK_FILE}';

CONNECT_TEST_TOPIC=connect-test
docker exec ${KRAFT_1_CONTAINER_NAME} ./bin/kafka-console-consumer.sh \
    --topic ${CONNECT_TEST_TOPIC} \
    --from-beginning --max-messages ${NO_MESSAGES} \
    --bootstrap-server ${KRAFT_1_CONTAINER_NAME}:${KRAFT_1_EXTERNAL_PORT};
