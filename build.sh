#!/bin/bash

source .env_template

# Build the image if needed
KAFKA_IMAGE="${DOCKERHUB_ACCOUNT}/${KAFKA_IMAGE_NAME}";
KAFKA_TAGGED_IMAGE="${KAFKA_IMAGE}:${KAFKA_IMAGE_VERSION}";
if [ -z "$(docker images | grep ${KAFKA_IMAGE})" ]; then
    cd kafka;
    docker build --pull -t ${KAFKA_TAGGED_IMAGE} .;
    cd ..;
fi

# Push the image
docker push ${KAFKA_TAGGED_IMAGE}

echo "${KAFKA_TAGGED_IMAGE} is ready ✅";
