#!/bin/bash

echo "Usage: ./set_public_ip.sh <public_ip>"
echo ""
echo "Use local ip: ./set_public_ip.sh"
echo "Use public ip: ./set_public_ip.sh 10.0.1.119"
echo ""

if [ $# -eq 1 ]; then
  export PUBLIC_IP=$1
  echo "Use public ip "$PUBLIC_IP

else
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)
      export PUBLIC_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
      ;;
    Darwin*)
      export PUBLIC_IP=`ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}'`
      ;;
    MINGW*)
      export PUBLIC_IP=`ipconfig | grep "IPv4" -A2 | grep -Fv 192.168 | grep IPv4 | grep -o '[^ ]*$'`
      ;;
    *)
      echo "Unsupported platform $unameOut."
      exit
      ;;
  esac
  echo "Use local ip "$PUBLIC_IP
fi

echo "Process(es) will listen on "$PUBLIC_IP"."

echo "Make sure following ports are accesible from outside this host:"
echo "kafka "
echo "  9002 (controller/broker)"