#!/bin/bash

CURRENT_DIR="$(pwd)"

export $(grep -v '^#' .docker_env | xargs)
KAFKA_IMAGE_NAME="${DOCKERHUB_ACCOUNT}/${KAFKA_IMAGE}:${KAFKA_IMAGE_VERSION}"
HAS_IMAGE="$(docker images | grep ${KAFKA_IMAGE_NAME})"
if [ -z $HAS_IMAGE ]; then
    cd kafka
    docker build --pull -t ${KAFKA_IMAGE_NAME} .
    # docker push ${KAFKA_IMAGE_NAME}
    cd $CURRENT_DIR
fi

echo "${KAFKA_IMAGE_NAME} is ready ✅";
