#!/bin/sh

docker compose down
docker system prune -a
sudo rm -rf vol*/