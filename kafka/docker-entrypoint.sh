#!/bin/bash

_term() {
    echo "🚨 Termination signal received...";
    kill -TERM "$child" 2>/dev/null
}

trap _term SIGINT SIGTERM

properties_file=/opt/kafka/config/kraft/server.properties;
echo ${KRAFT_ID} ${CLUSTER_IP} ${KRAFT_BROKER_PORT} ${KRAFT_CONTROLLER_PORT} ${KRAFT_EXTERNAL_PORT} ${KAFKA_STORAGE_UUID} ${KRAFT_CONTAINER_NAME} ${KRAFT_QUORUM_VOTERS}

echo "Setting up environment variables for ${KRAFT_ID} broker/controller ...";
echo "process.roles=broker,controller" | cat - $properties_file > temp && mv temp $properties_file;
echo "node.id=${KRAFT_ID}" | cat - $properties_file > temp && mv temp $properties_file;
echo "controller.quorum.voters=${KRAFT_QUORUM_VOTERS}" | cat - $properties_file > temp && mv temp $properties_file;
echo "inter.broker.listener.name=PLAINTEXT" >> $properties_file;
echo "controller.listener.names=CONTROLLER" >> $properties_file;
echo "listeners=PLAINTEXT://:${KRAFT_BROKER_PORT},CONTROLLER://:${KRAFT_CONTROLLER_PORT},EXTERNAL://:${KRAFT_EXTERNAL_PORT}" >> $properties_file;
echo "advertised.listeners=PLAINTEXT://${KRAFT_CONTAINER_NAME}:${KRAFT_BROKER_PORT},EXTERNAL://${CLUSTER_IP}:${KRAFT_EXTERNAL_PORT}" >> $properties_file;
echo "listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL,EXTERNAL:PLAINTEXT" >> $properties_file;
echo "log.dirs=/tmp/server/kraft-combined-logs" >> $properties_file;
echo "Environment variables afor ${KRAFT_ID} broker/controller are set ✅";

connect_properties=/opt/kafka/config/connect-standalone.properties;
sed -i 's/bootstrap.servers=localhost:9092/bootstrap.servers='${KRAFT_CONTAINER_NAME}':'${KRAFT_BROKER_PORT}'/' $connect_properties; 
sed -i 's/#plugin.path=/plugin.path=libs\/connect-file-3.3.1.jar/' $connect_properties;

echo "Setting up Kafka storage ...";
./bin/kafka-storage.sh format -t ${KAFKA_STORAGE_UUID} -c ./config/kraft/server.properties;
echo "Kafka storage ${KAFKA_STORAGE_UUID} setup ✅";

echo "Starting Kafka server...";
./bin/kafka-server-start.sh ./config/kraft/server.properties &
child=$!
echo "Kafka server ${KRAFT_CONTAINER_NAME} started ✅";

if [ "${KRAFT_ID}" = "1"]; then
    echo "Starting Kafka connect standalone ...";
    docker exec ${KRAFT_1_CONTAINER_NAME} ./bin/connect-standalone.sh \
        config/connect-standalone.properties \
        config/connect-file-source.properties \
        config/connect-file-sink.properties &
    echo "Kafka connect standalone started ✅";
fi

wait "$child";