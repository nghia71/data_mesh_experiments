#!/bin/bash

./stop.sh

echo "Pruning docker system ...";
docker system prune -a -f
echo "Docker system pruned ✅";

echo "Removing instance files ...";
rm .env
sudo rm -rf vol
echo "Instance files removed ✅";
