# ObservabilityPlatform
ObservabilityPlatform is an observability solution based on PromQL, LogQL, and openstracing, integrating deepflow for enhanced monitoring capabilities.

- 可观察性平台由以下角色组成：
  - K3S 集群相关的 Ansible playbook roles
    - k3s: 提供管理 k3s 集群的任务。
    - k3s-addon: 部署 k3s 附加组件。
    - k3s-reset: 将 k3s 集群重置为初始状态。
    - secret-manger: 部署 secret-manager 来管理敏感数据。
   - cert-manager: 部署 cert-manager 以颁发 TLS 证书。
- 容器集群相关的 Ansible playbook roles
  - observability-agent: 在 k3s 节点上部署可观察性代理。
  - observability-server: 部署可观察性服务器组件。
  - mysql: 部署 MySQL 以存储 Deepflow数据以及Grafana配置信息。
  - clickhouse: 部署 Clickhouse 以存储和分析时序数据。
  - alerting: 存储 Prometheus Alertmanager Rules 。
- 非容器vhosts相关的 Ansible playbook roles
  - node-exporter: 部署 node_exporter 来收集系统指标。
  - prometheus-transfer: 转发 Prometheus 将指标传输到远程存储。
  - promtail-agent: 部署 Promtail 从节点收集日志。

# API Endpoint

| name | URI |
| ---  | --- |
| querying(promql, logql, tempo) | http://data-gateway.<domian>                            |
| metrics_query                  | https://prometheus.<domian>/api/v1/query                |
| metrics_remote_write           | https://prometheus.<domian>/api/v1/remote/write         |
| logql_remote_write             | https://data-gateway.<domian>/loki/api/v1/push          |
| traces_tempo_push              | https://data-gateway.<domian>/tempo/api/push            |
| traces_zipkin_push             | https://data-gateway.<domian>/api/v2/spans              |
| traces_oltp_push               | https://data-gateway.<domian>/v1/traces                 |
| Query Traces                   | https://data-gateway.<domian>/api/traces/{traceId}      |
| Query Traces (JSON)	         | https://data-gateway.<domian>/api/traces/{traceId}/json |
