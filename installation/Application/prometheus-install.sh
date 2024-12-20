# Prometheus 커뮤니티 Helm 차트 저장소 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Helm 저장소 업데이트
helm repo update

# Prometheus 2.44.x 버전 설치
helm install prometheus prometheus-community/kube-prometheus-stack --version 45.0.0

# 설치된 Helm 릴리스 확인
helm list

# Prometheus 관련 pod들이 실행 중인지 확인
kubectl get pods -n monitoring

# 값 파일을 다운로드하여 수정
helm show values prometheus-community/kube-prometheus-stack > values.yaml

# values.yaml 파일 수정 후 Prometheus 재설치
helm upgrade prometheus prometheus-community/kube-prometheus-stack --version 45.0.0 -f values.yaml

# Prometheus 서비스 확인
kubectl get svc -n monitoring
