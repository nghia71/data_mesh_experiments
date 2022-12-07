#!/bin/sh

KAFKA_IMAGE="$(docker compose images | grep kafka)"
if [ -z $KAFKA_IMAGE ]; then
    docker compose build --pull nghiadh/kafka-kraft:latest
    echo "No topic requested for creation ✅";
fi

docker compose up -d