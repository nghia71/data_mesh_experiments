#!/bin/bash

./stop.sh

sed -i 's/CLUSTER_IP=.*/CLUSTER_IP=/' .env;
sed -i 's/KAFKA_STORAGE_UUID=.*/KAFKA_STORAGE_UUID=/' .env;

echo "Pruning docker system ...";
docker system prune -a -f
echo "Docker system pruned ✅";

echo "Removing instance files ...";
rm -rf vol
echo "Instance files removed ✅";
