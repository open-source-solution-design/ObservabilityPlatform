# clickhouse-keeper-on-k8s
clickhouse cluster with clickhouse-keeper on k8s

# password 
echo -n password | openssl dgst -sha256

# set node label
kubectl label nodes ip-10-100-0-102 prometheus=true
kubectl label nodes ip-10-100-0-102 arch=amd64
kubectl label nodes ip-10-100-0-102 node=database
