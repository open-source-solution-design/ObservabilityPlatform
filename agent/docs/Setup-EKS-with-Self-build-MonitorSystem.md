# Prep Options

## Server config
```
curl -o /usr/bin/deepflow-ctl https://deepflow-ce.oss-cn-beijing.aliyuncs.com/bin/ctl/stable/linux/$(arch | sed 's|x86_64|amd64|' | sed 's|aarch64|arm64|')/deepflow-ctl
chmod a+x /usr/bin/deepflow-ctl

unset CLUSTER_NAME
CLUSTER_NAME="cluster_name"  # FIXME: K8s cluster name
cat << EOF | deepflow-ctl domain create -f -
name: $CLUSTER_NAME
type: kubernetes
EOF
deepflow-ctl domain list $CLUSTER_NAME  # Get K8sClusterID
```

## client config
```
kubectl get nodes
kubectl label nodes node-xxxx prometheus=true --overwrite
```

# Install Agent
```
cat > values.yaml << EOF
kube-state-metrics:
  enabled: false
prometheus-to-cloudwatch:
  enabled: false
deepflow-agent:
  enabled: true
  deepflowServerNodeIPS:
    - 161.189.105.101
  deepflowK8sClusterID: d-3CdBjFev1Y
prometheus:
  enabled: true
  server:
    extraFlags:
    - enable-feature=expand-external-labels
    remoteWrite:
    - name: remote_prometheus
      url: 'https://prometheus.onwalk.net/api/v1/write'
  alertmanager:
    enabled: false
  prometheus-pushgateway:
    enabled: false
  kube-state-metrics:
    image:
      repository: artifact.onwalk.net/k8s/kube-state-metrics
      tag: v2.7.0
fluent-bit:
  enabled: true
  logLevel: debug
  image:
    repository: artifact.onwalk.net/k8s/fluent-bit
    tag: "2.0.8"
    pullPolicy: Always
  config:
    outputs: |
      [OUTPUT]
          Name        loki
          Match kube.*
          Host        loki.onwalk.net
          port        443
          tls         on
          tls.verify  on
EOF

helm repo add stable https://artifact.onwalk.net/chartrepo/k8s/
helm repo update
helm upgrade --install observableagent stable/observableagent -n monitoring --create-namespace -f values.yaml
```

## Post setup
add cluster label

kubectl  edit cm observableagent-prometheus-server -n monitoring
```
  prometheus.yml: |
    global:
      external_labels:
        cluster: app-dev
```

# Configure


# LiveDemo

# Reference 

- https://github.com/jtblin/kube2iam
- https://grafana.github.io/helm-charts
- https://deepflowys.github.io/deepflow
- https://prometheus-community.github.io/helm-charts
- https://github.com/fluent/fluent-bit-docs/blob/43c4fe134611da471e706b0edb2f9acd7cdfdbc3/administration/aws-credentials.md

# Todo

## Dev Reference 
- https://github.com/YunaiV/ruoyi-vue-pro
- https://github.com/todoadmin/vue-admin-chart
- https://github.com/ClaudioWaldvogel/cloudwatch-loki-shipper
- https://github.com/cpsrepositorio/cps-marketplace-layout
- https://github.com/Hayaking/clickhouse-keeper-on-k8s
