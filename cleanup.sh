#!/bin/bash

./stop.sh

sed -i 's/LOCAL_IP=/LOCAL_IP='${LOCAL_IP}'/' .env;
sed -i 's/KAFKA_STORAGE_UUID=/KAFKA_STORAGE_UUID='${KAFKA_STORAGE_UUID}'/' .env;

echo "Pruning docker system ...";
docker system prune -a -f
echo "Docker system pruned ✅";

echo "Removing instance files ...";
rm .env
sudo rm -rf vol
echo "Instance files removed ✅";
