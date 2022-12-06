#!/bin/sh

KAFKA_STORAGE_UUID="$(cat /proc/sys/kernel/random/uuid | tr -d '-' | base64 | cut -b 1-22)"
sed -i 's/KAFKA_STORAGE_UUID=/KAFKA_STORAGE_UUID=${KAFKA_STORAGE_UUID}/' .env
echo 
