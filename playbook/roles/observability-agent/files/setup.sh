#!/bin/bash
set -x
export observableserver=$1
export deepflowserverip=$2
export deepflowk8sclusterid=$3

cat > values.yaml << EOF
kube-state-metrics:
  enabled: true
deepflow-agent:
  enabled: true
  deepflowServerNodeIPS:
    - $deepflowserverip
  deepflowK8sClusterID: $deepflowk8sclusterid
prometheus:
  enabled: true
  server:
    extraFlags:
    - enable-feature=expand-external-labels
    - web.enable-lifecycle
    remoteWrite:
    - name: remote_prometheus
      url: 'https://${observableserver}/api/v1/write'
  alertmanager:
    enabled: false
  rometheus-pushgateway:
    enabled: false
promtail:
  enabled: true
  config:
    clients:
      - url: http://${observableserver}/loki/api/v1/push
fluent-bit:
  enabled: false
  logLevel: debug
  config:
    outputs: |
      [OUTPUT]
          Name        loki
          Match       kube.*
          Host        $observableserver
          port        $port
          tls         on
          tls.verify  on
EOF

node_name=`kubectl get nodes | awk 'NR>1 {print $1}'`
kubectl create namespace monitoring || echo true
kubectl label nodes $node prometheus=true --overwrite || echo true
helm repo add stable https://charts.onwalk.net/ || echo true
helm repo update
helm upgrade --install observableagent stable/observabilityagent -n monitoring -f values.yaml
