#!/bin/bash

# export HELM_REPO_PASSWORD=xxxxx 

# prep build env
sudo apt update
sudo apt install git -y
sudo timedatectl set-timezone "$TZ"

# install build tools
sudo curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm plugin install https://github.com/chartmuseum/helm-push.git
helm repo add neo4j https://helm.neo4j.com/neo4j
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add deepflow https://deepflowys.github.io/deepflow
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
echo "$HELM_REPO_PASSWORD" | helm repo add sync --username=admin --password-stdin https://artifact.onwalk.net/chartrepo/k8s/
helm repo up

# clone repo && sync upstream charts 
rm *.tgz -f
git clone https://github.com/solo-cat/ObservableStack.git
cd ObservableStack/charts
rm -rvf neo4j && helm fetch neo4j/neo4j --untar
rm -rvf loki && helm fetch grafana/loki --untar
rm -rvf grafana && helm fetch grafana/grafana --untar
rm -rvf deepflow && helm fetch deepflow/deepflow --untar
rm -rvf prometheus && helm fetch prometheus-community/prometheus  --untar
rm -rvf alertmanager && helm fetch prometheus-community/alertmanager --untar
rm *.tgz -f && helm package ./ &&  helm cm-push ObservableServer-${TAG}.tgz sync

# upstream merge
git config user.name shenlan
git config user.email manbuzhe2009@qq.com
rm *.tgz -f
git add -A
git commit -a -m "Merged: Upstream Repo"
git push
