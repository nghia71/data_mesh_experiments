#!/bin/sh

CURRENT_DIR="$(pwd)"

export $(grep -v '^#' .env | xargs)

KAFKA_IMAGE_NAME="${DOCKERHUB_ACCOUNT}/${KAFKA_IMAGE}:${KAFKA_IMAGE_VERSION}"
HAS_IMAGE="$(docker image inspect ${KAFKA_IMAGE_NAME})"
if [ -z $HAS_IMAGE ]; then
    cd kafka
    docker build --pull -t ${KAFKA_IMAGE_NAME} .
    cd $CURRENT_DIR
fi
echo "${KAFKA_IMAGE_NAME} is ready ✅";
