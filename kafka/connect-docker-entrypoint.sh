#!/bin/bash

_term() {
    echo "🚨 Termination signal received...";
    kill -TERM "$child" 2>/dev/null
}

trap _term SIGINT SIGTERM

echo ${KAFKA_CONNECT_STANDALONE} ${KAFKA_CONNECT_PORT} ${KAFKA_CONNECT_VOL} ${KRAFT_CONTAINER_NAME} ${KRAFT_BROKER_PORT}

properties_file=/opt/kafka/config/connect-standalone.properties;
echo "Setting up environment variables for ${KAFKA_CONNECT_STANDALONE} connect-standalone.properties ...";
sed -i 's/bootstrap.servers=localhost:9092/bootstrap.servers='${KRAFT_CONTAINER_NAME}':'${KRAFT_BROKER_PORT}'/' $properties_file; 
sed -i 's/#plugin.path=/plugin.path=libs\/connect-file-3.3.1.jar/' $properties_file;
echo "Environment variables for ${KAFKA_CONNECT_STANDALONE} connect-standalone.properties are set ✅";

properties_file=/opt/kafka/config/connect-file-source.properties;
echo "Setting up environment variables for ${KAFKA_CONNECT_STANDALONE} connect-file-source.properties ...";
sed -i 's/file=test.txt/file='${KAFKA_CONNECT_SOURCE_FILE}'/' $properties_file; 
sed -i 's/topic=connect-test/topic='${KAFKA_CONNECT_SOURCE_TOPIC}'/' $properties_file; 
echo "Environment variables for ${KAFKA_CONNECT_STANDALONE} connect-file-source.properties are set ✅";

properties_file=/opt/kafka/config/connect-file-sink.properties;
echo "Setting up environment variables for ${KAFKA_CONNECT_STANDALONE} connect-file-sink.properties ...";
sed -i 's/file=test.txt/file='${KAFKA_CONNECT_SINK_FILE}'/' $properties_file; 
sed -i 's/topic=connect-test/topic='${KAFKA_CONNECT_SINK_TOPIC}'/' $properties_file; 
echo "Environment variables for ${KAFKA_CONNECT_STANDALONE} connect-file-sink.properties are set ✅";

echo "Starting Kafka ${KAFKA_CONNECT_STANDALONE} ...";
./bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties &
child=$!
echo "Kafka ${KAFKA_CONNECT_STANDALONE} started ✅";

wait "$child";