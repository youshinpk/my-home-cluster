# Prometheus Helm 차트 리포지토리 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Grafana Helm 차트 리포지토리 추가
helm repo add grafana https://grafana.github.io/helm-charts

# Helm 차트 업데이트
helm repo update

# Prometheus 설치 (prometheus 네임스페이스 생성)
helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus --create-namespace
