# Get the current version of an application in production,
# based on its deployment name and its namespace.
#.
# Usage: kversion DEPLOYMENT_NAME NAMESPACE
# - DEPLOYMENT_NAME: Do 'kubectl get deploy -n NAMESPACE' to see the list of available apps
# - NAMESPACE:       bhc, totalbelgium, totalspain
kversion(){
    require jq yq || return 1

    local app_name="$1"
    local namespace="$2"

    if [ -z "$app_name" ] || [ -z "$namespace" ]; then
        echo "Description: Get the current version of an application in production,"
        echo "             based on its deployment name and its namespace."
        echo ""
        echo "Usage: kversion DEPLOYMENT_NAME NAMESPACE"
        echo "- DEPLOYMENT_NAME: Do 'kubectl get deploy -n NAMESPACE' to see the list of available apps"
        echo "- NAMESPACE:       bhc, totalbelgium, totalspain"
        echo ""
        return
    fi

    kubectl get deploy "$app_name" -o yaml  -n "$namespace" | yq '.metadata.annotations."kubectl.kubernetes.io/last-applied-configuration"' | jq '.spec.template.spec.containers[0].image'
}

# Decypher and print a kubernetes secrets based on it's name
# Optional namespace 2nd parameter
# Usage:
# ksecrets <secret_name> [namespace_name]
ksecrets(){
    require jq || return 1

    local app_name="$1"
    local namespace="$2"
    if [ -z "$app_name" ]; then
        echo "Description: A command to get decoded secrets data from a secret (no base64 decode required)"
        echo "Usage: ksecrets SECRET_NAME"
        echo ""
        echo "Use 'kubectl get secrets' to see what is available"
        echo "Use 'kns NAMESPACE' to go to the right namespace"
        return
    fi

    if [ -z "$namespace" ]; then
        kubectl get secret "$app_name" -o json | jq '{name: .metadata.name,data: .data|map_values(@base64d)}'
    else
        kubectl get secret "$app_name" -n "$namespace" -o json | jq '{name: .metadata.name,data: .data|map_values(@base64d)}'
    fi
}

# Kubernetes env vars from all pods in a deployment
# Optional namespace 2nd parameter
# Usage:
# kenv <secret_name> [namespace_name]
kenv_deploy(){
    local app_name="$1"
    local namespace="$2"
    if [ -z "$app_name" ]; then
        echo "Description: A command to get decoded secrets data from a secret (no base64 decode required)"
        echo "Usage: ksecrets SECRET_NAME"
        echo ""
        echo "Use 'kubectl get secrets' to see what is available"
        echo "Use 'kns NAMESPACE' to go to the right namespace"
        return
    fi

    if [ -z "$namespace" ]; then
        res="$(kubectl get deploy $app_name -o jsonpath='{.spec.template.spec.containers[*].env}')"
    else
        res="$(kubectl get deploy $app_name -n $namespace -o jsonpath='{.spec.template.spec.containers[*].env}')"
    fi

    if require jq; then
        printf '%s\n' "$res" | jq .
    else
        printf '%s\n' "$res"
    fi
}


# A simple script to copy paste your Rancher credentials to your terminal
# just click on "Copy KubeConfig to clipboard"
# .
#Usage:
# 
# rancher_kubeconfig_update "<paste your kubeconfig from rancher web here>"
# .
#outputs:
# Cluster "eu-prod02" set.
# User "eu-prod02" set.
# Context "eu-prod02" modified.
rancher_kubeconfig_update(){
    require kubectl yq || return 1

    local kubeconfig_paste_from_rancher="$1"
    local path_to_kubeconfig="$HOME/.kube/config"    
    local cluster_name=$(echo "$kubeconfig_paste_from_rancher" | yq ".current-context")
    local cluster_server=$(echo "$kubeconfig_paste_from_rancher" | yq ."clusters[0].cluster.server")
    local user_token=$(echo "$kubeconfig_paste_from_rancher" | yq ".users[0].user.token")
    kubectl config set-cluster "$cluster_name" --server="$cluster_server"
    kubectl config set-credentials "$cluster_name" --token="$user_token"
    kubectl config set-context "$cluster_name" 
}