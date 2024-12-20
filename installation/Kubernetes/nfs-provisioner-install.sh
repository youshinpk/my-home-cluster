#!/bin/bash

# NFS Client Provisioner Helm 저장소 추가
helm repo add nfs-provisioner https://kubernetes-sigs.github.io/nfs-provisioner
helm repo update

# 설치할 네임스페이스 생성
kubectl create namespace nfs-provisioner

# 설치할 폴더 생성
mkdir k8s-volume

# NFS Client Provisioner 설치 (NFS 서버 주소와 경로를 사용자 환경에 맞게 설정)
#helm install nfs-client-provisioner nfs-provisioner/nfs-provisioner -n nfs-provisioner \
#  --set nfs.server=<nfs-server-ip> \
#  --set nfs.path=<nfs-share-path>

helm install nfs-client-provisioner nfs-provisioner/nfs-provisioner -n nfs-provisioner \
  --set nfs.server=192.168.1.11 \
  --set nfs.path=k8s-volume


# 설치 후 프로비저너 상태 확인
kubectl get pod -n nfs-provisioner