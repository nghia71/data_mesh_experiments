#!/bin/bash

echo "Prepare Kafka image...";
source .docker_env;
KAFKA_IMAGE="${DOCKERHUB_ACCOUNT}/${KAFKA_IMAGE_NAME}";
KAFKA_TAGGED_IMAGE="${KAFKA_IMAGE}:${KAFKA_IMAGE_VERSION}";
if [ -z "$(docker images | grep ${KAFKA_IMAGE})" ]; then
    CURRENT_UID=$(id -u):$(id -g) docker compose pull -t ${KAFKA_IMAGE_NAME};
fi
echo "Kafka image ${KAFKA_TAGGED_IMAGE} are ready ✅";

echo "Seting up Kafka storage UUID ...";
KAFKA_STORAGE_UUID="$(uuidgen | tr -d '-' | base64 | cut -b 1-22)"
sed 's/KAFKA_STORAGE_UUID=.*/KAFKA_STORAGE_UUID='${KAFKA_STORAGE_UUID}'/' .kafka_env > .env
echo "Kafka storage UUID is set to ${KAFKA_STORAGE_UUID} ✅";

echo "Create volumes for data and logs ...";
source .env;
NUMER_OF_KAFKA_INSTANCES=$(set | grep KRAFT_._ID | wc -l)
i=1
while [[ $i -le $NUMER_OF_KAFKA_INSTANCES ]]
do
    DATA_DIR_VAR="KRAFT_${i}_DATA_VOL";
    DATA_DIR="${!DATA_DIR_VAR}";
    LOGS_DIR_VAR="KRAFT_${i}_LOGS_VOL";
    LOGS_DIR="${!LOGS_DIR_VAR}";

    mkdir -p ${DATA_DIR};
    mkdir -p ${LOGS_DIR};
    chown -R $(id -u):$(id -g) ${DATA_DIR};
    chown -R $(id -u):$(id -g) ${LOGS_DIR};

    ((i = i + 1))
done
echo "Volumes for Kafka data and logs are created ✅";
