#!/bin/bash

# Istio 공식 Helm 저장소 추가
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# Istio 네임스페이스 생성 (istio-system)
kubectl create namespace istio-system

# Istio를 기본값으로 설치 (설치 옵션을 변경하려면 `values.yaml` 파일을 사용할 수 있습니다)
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system

# Istio Ingress Gateway 설치 (옵션)
helm install istio-ingress istio/gateway -n istio-system

# 설치된 Istio 상태 확인
kubectl get pods -n istio-system

# Istio 버전 확인
kubectl exec -n istio-system -it $(kubectl get pod -n istio-system -l app=istiod -o jsonpath='{.items[0].metadata.name}') -- istioctl version