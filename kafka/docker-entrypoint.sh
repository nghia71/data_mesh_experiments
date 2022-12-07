#!/bin/bash

_term() {
    echo "🚨 Termination signal received...";
    kill -TERM "$child" 2>/dev/null
}

trap _term SIGINT SIGTERM

properties_file=/opt/kafka/config/kraft/server.properties;

echo "Applying environment variables ...";
echo "process.roles=broker,controller" | cat - $properties_file > temp && mv temp $properties_file;
echo "node.id=${KRAFT_ID}" | cat - $properties_file > temp && mv temp $properties_file;
echo "controller.quorum.voters=${KRAFT_QUORUM_VOTERS}" | cat - $properties_file > temp && mv temp $properties_file;
echo "inter.broker.listener.name=PLAINTEXT" >> $properties_file;
echo "controller.listener.names=CONTROLLER" >> $properties_file;
echo "listeners=PLAINTEXT://:${KRAFT_BROKER_PORT},CONTROLLER://:${KRAFT_CONTROLLER_PORT}" >> $properties_file;
echo "listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL" >> $properties_file;
echo "log.dirs=/tmp/server/kraft-combined-logs" >> $properties_file;
echo "Environment variables applied ✅";

echo "Setting up Kafka storage ...";
./bin/kafka-storage.sh format -t $KAFKA_STORAGE_UUID -c ./config/kraft/server.properties;
echo "Kafka storage ${KAFKA_STORAGE_UUID} setup ✅";

echo "Starting Kafka server...";
./bin/kafka-server-start.sh ./config/kraft/server.properties &
child=$!
echo "Kafka server ${KRAFT_HOST_NAME} started ✅";

wait "$child";