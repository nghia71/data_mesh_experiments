#!/bin/bash

_term() {
    echo "🚨 Termination signal received...";
    kill -TERM "$child" 2>/dev/null
}

trap _term SIGINT SIGTERM

properties_file=/opt/kafka/config/kraft/server.properties;
kafka_addr=$KRAFT_HOST_NAME:$KRAFT_BROKER_PORT;
echo $KRAFT_QUORUM_VOTERS

echo "Applying environment variables ...";
echo "process.roles=broker,controller" | cat - $properties_file > temp && mv temp $properties_file;
echo "node.id=${KRAFT_ID}" | cat - $properties_file > temp && mv temp $properties_file;
echo "controller.quorum.voters=${KRAFT_QUORUM_VOTERS}" | cat - $properties_file > temp && mv temp $properties_file;
echo "inter.broker.listener.name=PLAINTEXT" >> $properties_file;
echo "controller.listener.names=CONTROLLER" >> $properties_file;
echo "listeners=PLAINTEXT://:${KRAFT_BROKER_PORT},CONTROLLER://:${KRAFT_CONTROLLER_PORT}" >> $properties_file;
echo "listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL" >> $properties_file;
echo "log.dirs=/tmp/server${KRAFT_ID}/kraft-combined-logs" >> $properties_file;
echo "Enivronment variables applied ✅";

echo "Setting up Kafka storage ...";
export suuid=$(./bin/kafka-storage.sh random-uuid);
./bin/kafka-storage.sh format -t $suuid -c ./config/kraft/server.properties;
echo "Kafka storage setup ✅";


echo "Starting Kafka server...";
./bin/kafka-server-start.sh ./config/kraft/server.properties &
child=$!
echo "Kafka server started ✅";

if [ -z $KRAFT_CREATE_TOPICS ]; then
    echo "No topic requested for creation ✅";
else
    echo "Creating topics ...";
    ./wait-for-it.sh $kafka_addr;

    pc=1
    if [ $KRAFT_PARTITIONS_PER_TOPIC ]; then
        pc=$KRAFT_PARTITIONS_PER_TOPIC
    fi

    for i in $(echo $KRAFT_CREATE_TOPICS | sed "s/,/ /g")
    do
        ./bin/kafka-topics.sh --create --topic "$i" --partitions "$pc" --replication-factor 1 --bootstrap-server $kafka_addr;
    done
    echo "Requested topics created ✅";
fi

wait "$child";