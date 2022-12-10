#!/bin/bash

echo "Prepare Kafka image...";
CURRENT_UID=$(id -u):$(id -g) docker compose build;
echo "Kafka image ${KAFKA_TAGGED_IMAGE} are ready ✅";

echo "Seting up Kafka storage UUID ...";
KAFKA_STORAGE_UUID="$(uuidgen | tr -d '-' | base64 | cut -b 1-22)";
sed -i 's/KAFKA_STORAGE_UUID=.*/KAFKA_STORAGE_UUID='${KAFKA_STORAGE_UUID}'/' .env;
echo "Kafka storage UUID is set to ${KAFKA_STORAGE_UUID} ✅";

CLUSTER_IP=$(ip addr show $(ip route | awk '/default/ { print $5 }' | head -n 1) | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1)
sed -i 's/CLUSTER_IP=.*/CLUSTER_IP='${CLUSTER_IP}'/' .env;
echo "Local IP is set to ${CLUSTER_IP} ✅";

source .env

echo "Create volumes for data and logs ...";
NUMER_OF_KAFKA_INSTANCES=$(set | grep KRAFT_._ID | wc -l)
i=1
while [[ $i -le $NUMER_OF_KAFKA_INSTANCES ]]
do
    DATA_DIR_VAR="KRAFT_${i}_DATA_VOL";
    DATA_DIR="${!DATA_DIR_VAR}";
    LOGS_DIR_VAR="KRAFT_${i}_LOGS_VOL";
    LOGS_DIR="${!LOGS_DIR_VAR}";
    echo $DATA_DIR $LOGS_DIR;

    mkdir -p ${DATA_DIR};
    mkdir -p ${LOGS_DIR};
    chown -R $(id -u):$(id -g) ${DATA_DIR};
    chown -R $(id -u):$(id -g) ${LOGS_DIR};

    ((i = i + 1))
done

mkdir -p ${KRAFT_FILE_LOADER_DATA_VOL}
chown -R $(id -u):$(id -g) ${KRAFT_FILE_LOADER_DATA_VOL}

echo "Volumes for Kafka data and logs are created ✅";
