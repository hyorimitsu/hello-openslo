#!/bin/bash

if [ "x$1" = "xrun" ]; then
    if [ ! -d "$HOME/.minikube/machines/$PROJECT_NAME" ]; then
        # Initial startup
        minikube start --driver=virtualbox --profile "$PROJECT_NAME"
        minikube addons enable ingress --profile "$PROJECT_NAME"
        # Update /etc/hosts
        ./script/host-updater.sh "$PROJECT_NAME"
    else
        # On second or subsequent startup
        minikube start --driver=virtualbox --profile "$PROJECT_NAME"
    fi
    # Wait until Ingress is Ready
    INGRESS_CONTROLLER_NAME=$(kubectl get pods -o custom-columns=":metadata.name" -n ingress-nginx | grep ingress-nginx-controller)
    kubectl wait --for condition=Ready pod/$INGRESS_CONTROLLER_NAME -n ingress-nginx
    sleep 30
    # Skaffold startup
    skaffold dev

elif [ "x$1" = "xstop" ]; then
    skaffold delete
    minikube stop --profile "$PROJECT_NAME"

elif [ "x$1" = "xlogs" ]; then
    NAMESPACES=("hello-openslo")
    for NS in ${NAMESPACES[@]}; do
        POD_NAME=$(kubectl get pods -o custom-columns=":metadata.name" -n "$NS" | grep "$2")
        if [ "$POD_NAME" != "" ]; then
            echo "[namespace: $NS, pod: $POD_NAME] logs..."
            kubectl logs "$POD_NAME" -n "$NS"
        fi
    done

elif [ "x$1" = "xdashboard" ]; then
    minikube dashboard -p "$PROJECT_NAME"

elif [ "x$1" = "xdestroy" ]; then
    minikube delete --profile "$PROJECT_NAME"

else
    echo "You have to specify which action to be excuted. [ run / stop / logs / dashboard / destroy ]" 1>&2
    exit 1
fi
