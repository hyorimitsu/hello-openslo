#!/bin/bash

set -e

MINIKUBE_IP=$(minikube ip -p $1)
INGRESSES_HOST="$1.localhost.com"
HOSTS_ENTRY="$MINIKUBE_IP $INGRESSES_HOST"

if grep -Fq "$INGRESSES_HOST" /etc/hosts > /dev/null
then
    sudo sed -i '' "s/.*$INGRESSES_HOST$/$HOSTS_ENTRY/" /etc/hosts
    echo "Updated hosts entry => '$HOSTS_ENTRY'"
else
    echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts
    echo "Added hosts entry => '$HOSTS_ENTRY'"
fi
