#!/bin/bash

source .docker_env;
KAFKA_IMAGE="${DOCKERHUB_ACCOUNT}/${KAFKA_IMAGE_NAME}";
KAFKA_TAGGED_IMAGE="${KAFKA_IMAGE}:${KAFKA_IMAGE_VERSION}";
if [ -z "$(docker images | grep ${KAFKA_IMAGE})" ]; then
    echo 'no images'
    cd kafka;
    docker build --user $(id -u):$(id -g) -t ${KAFKA_TAGGED_IMAGE} .;
    cd ..;
fi

# Push the image if needed
# docker push ${KAFKA_TAGGED_IMAGE}

echo "${KAFKA_TAGGED_IMAGE} is ready ✅";
