#!/bin/bash

echo "Prepare Kafka image...";
CURRENT_UID=$(id -u):$(id -g) docker compose build;
echo "Kafka image ${KAFKA_TAGGED_IMAGE} are ready ✅";

echo "Seting up Kafka storage UUID ...";
KAFKA_STORAGE_UUID="$(uuidgen | tr -d '-' | base64 | cut -b 1-22)";
sed -i 's/KAFKA_STORAGE_UUID=.*/KAFKA_STORAGE_UUID='${KAFKA_STORAGE_UUID}'/';
echo "Kafka storage UUID is set to ${KAFKA_STORAGE_UUID} ✅";

source .env;

echo "Create volumes for data and logs ...";
NUMER_OF_KAFKA_INSTANCES=$(set | grep KRAFT_._ID | wc -l)
i=1
while [[ $i -le $NUMER_OF_KAFKA_INSTANCES ]]
do
    DATA_DIR_VAR="KRAFT_${i}_DATA_VOL";
    DATA_DIR="${!DATA_DIR_VAR}";
    LOGS_DIR_VAR="KRAFT_${i}_LOGS_VOL";
    LOGS_DIR="${!LOGS_DIR_VAR}";
    CONF_DIR_VAR="KRAFT_${i}_CONF_VOL";
    CONF_DIR="${!CONF_DIR_VAR}";

    mkdir -p ${DATA_DIR};
    mkdir -p ${LOGS_DIR};
    mkdir -p ${CONF_DIR};
    chown -R $(id -u):$(id -g) ${DATA_DIR};
    chown -R $(id -u):$(id -g) ${LOGS_DIR};
    chown -R $(id -u):$(id -g) ${CONF_DIR};

    ((i = i + 1))
done
echo "Volumes for Kafka data and logs are created ✅";
