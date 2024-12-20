#!/bin/bash

# Helm 저장소 추가
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Argo CD를 설치할 네임스페이스 생성
kubectl create namespace argocd

# Argo CD 설치 (stable/argo-helm)
helm install argocd argo/argo-cd -n argocd

# 설치 후 Argo CD의 서비스 확인
kubectl get svc -n argocd

# Argo CD의 UI에 접근하기 위한 포트 포워딩 (기본 포트 8080)
kubectl port-forward svc/argocd-server -n argocd 8080:80