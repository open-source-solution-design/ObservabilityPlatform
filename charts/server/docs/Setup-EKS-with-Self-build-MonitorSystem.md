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
  enabled: true
  grafana:
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
prometheus:
  kube-state-metrics:
    image:
      repository: artifact.onwalk.net/k8s/kube-state-metrics
      tag: v2.7.0
  server:
    nodeSelector:
      web: observable
    ingress:
      ingressClassName: nginx
      hosts:
        - prometheus.onwalk.net
      tls:
        - secretName: observable-server-tls
          hosts:
            - prometheus.onwalk.net
    alertmanagers:
    - static_configs:
      - targets:
        - alertmanager.onwalk.net
  serverFiles:
    prometheus.yml:
      rule_files:
        - /etc/config/recording_rules.yml
        - /etc/config/alerting_rules.yml
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
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: alertmanager.onwalk.net
    tls:
       - secretName: observable-server-tls
         hosts:
           - alertmanager.onwalk.net
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

helm repo add stable https://artifact.onwalk.net/chartrepo/k8s/
helm repo update
helm upgrade --install observable-server stable/observableserver -n monitoring -f values.yaml 
```

# Configure

* https://grafana.your.domain  admin/deepflow
* https://loki.your.domain
* https://prometheus.your.domain
* https://alertmanager.your.domain
