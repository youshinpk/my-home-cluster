#!/bin/bash

# Harbor의 Helm 저장소 추가
helm repo add harbor https://helm.goharbor.io
helm repo update

# Harbor를 설치할 네임스페이스 생성
kubectl create namespace harbor

# Harbor 설치 (기본 설정으로 설치)
helm install harbor harbor/harbor -n harbor

# 설치 후 Harbor의 서비스 확인
kubectl get svc -n harbor

# Harbor의 포트 포워딩 (기본 포트 80, 443)
kubectl port-forward svc/harbor-harbor-core -n harbor 8080:80