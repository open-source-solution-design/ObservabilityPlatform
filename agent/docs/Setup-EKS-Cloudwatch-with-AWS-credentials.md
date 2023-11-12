```
cat > values.yaml << EOF
kube-state-metrics:
  enabled: true
prometheus-to-cloudwatch:
  enabled: true
  replicaCount: 1
  env:
    AWS_ACCESS_KEY_ID: xxxxxxxx
    AWS_SECRET_ACCESS_KEY: xxxxxxx
    CLOUDWATCH_NAMESPACE: "app-dev"
    CLOUDWATCH_REGION: "cn-northwest-1"
    PROMETHEUS_SCRAPE_URL: 'http://observableagent-kube-state-metrics.monitoring.svc.cluster.local:8080/metrics'
fluent-bit:
  enabled: true
  env:
    - name: AWS_ACCESS_KEY_ID
      value: "xxxxxx"
    - name: AWS_SECRET_ACCESS_KEY
      value: "xxxxxx"
  image:
    repository: artifact.onwalk.net/k8s/fluent-bit
    tag: "2.0.8"
    pullPolicy: Always
  config:
    outputs: |
      [OUTPUT]
          Name cloudwatch_logs
          region cn-northwest-1
          Match kube.*
          log_group_name  /aws/eks/app-dev/cluster/
          log_stream_name app_dev
          auto_create_group true
EOF

helm repo add stable https://artifact.onwalk.net/chartrepo/k8s/
helm repo update
helm upgrade --install observableagent stable/observableagent -n monitoring --create-namespace -f values.yaml 
