# Overview

![ObservableArch](/scripts/pic/ObservableArchDesign.jpg "ObservableArch")

# Prep

# Install

```
kubectl get nodes
kubectl label nodes node-xxxx prometheus=true --overwrite
kubectl create ns monitoring
kubectl create secret tls observable-server-tls --cert=your.domain.pem --key=your.domain.key -n monitoring

cat > values.yaml << EOF
global:
  domain: onwalk.net
  namespace: monitoring
  secretName: observable-server-tls
deepflow:
  server:
    nodeSelector:
      web: observable
  enabled: true
  clickhouse:
    enabled: false
  mysql:
    enabled: false
  grafana:
    nodeSelector:
      web: observable
    enabled: true
    ingress:
      enabled: true
      ingressClassName: nginx
      hosts:
        - grafana.onwalk.net
      tls:
        - secretName: observable-server-tls
          hosts:
            - grafana.onwalk.net
  global:
    externalClickHouse:
      enabled: true
      type: ep
      clusterName: default
      storagePolicy: default
      username: default
      password: <DB_PassWord>
      hosts:
      - ip: 10.1.2.3
        port: 9000
      - ip: 10.1.2.4
        port: 9000
      - ip: 10.1.2.5
        port: 9000
    externalMySQL:
      enabled: true
      ip: mysql.database.svc.cluster.local
      port: 3306
      username: root
      password: <DB_PassWord>
prometheus:
  server:
    nodeSelector:
      web: observable
  serverFiles:
    alerting_rules.yml:
      groups:
        - name: Instances
          rules:
            - alert: InstanceDown
              expr: up == 0
              for: 5m
              labels:
                severity: page
              annotations:
                description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
                summary: 'Instance {{ $labels.instance }} down'
      recording_rules.yml: {}
alertmanager:
  nodeSelector:
    web: observable
  configmapReload:
    enabled: false
  config:
    global:
      resolve_timeout: 5m #超时,默认5min
      smtp_smarthost: 'smtp.qq.com:465'
      smtp_from: '11111111@qq.com'
      smtp_auth_username: '11111111@qq.com'
      smtp_auth_password: '123456'
      smtp_require_tls: false
    templates:
      - '/etc/alertmanager/*.tmpl'
    receivers:
      - name: 'default-receiver'
        email_configs:
        - to: '{{ template "email.to" . }}'
          html: '{{ template "email.to.html" . }}'
    route:
      group_wait: 10s
      group_interval: 5m
      receiver: default-receiver
      repeat_interval: 1h
EOF

helm repo add stable https://artifact.onwalk.net/chartrepo/public/
helm repo update
helm upgrade --install observable-server stable/observableserver -n monitoring -f values.yaml 
```

# Configure

* https://grafana.your.domain  admin/deepflow
* https://loki.your.domain
* https://prometheus.your.domain
* https://alertmanager.your.domain
