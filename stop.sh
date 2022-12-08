#!/bin/bash

echo "Stopping all services ...";
CURRENT_UID=$(id -u):$(id -g) docker compose down
echo "All services are stopped ✅";
