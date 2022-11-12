#!/bin/bash

if [ "x$1" = "xrun" ]; then
    if [ ! -d "$HOME/.minikube/machines/$PROJECT_NAME" ]; then
        # 初回起動時
        minikube start --driver=virtualbox --profile "$PROJECT_NAME"
        minikube addons enable ingress --profile "$PROJECT_NAME"
        # /etc/hosts 更新
        ./script/host-updater.sh "$PROJECT_NAME"
    else
        # 2回目以降の起動時
        minikube start --driver=virtualbox --profile "$PROJECT_NAME"
    fi
    # Ingress が Ready になるまで待機
    INGRESS_CONTROLLER_NAME=$(kubectl get pods -o custom-columns=":metadata.name" -n ingress-nginx | grep ingress-nginx-controller)
    kubectl wait --for condition=Ready pod/$INGRESS_CONTROLLER_NAME -n ingress-nginx
    sleep 30
    # Skaffold 起動
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
