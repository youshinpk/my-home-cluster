#!/bin/bash

# Helm의 최신 버전 다운로드 URL
HELM_VERSION="v3.12.0"  # 원하는 Helm 버전으로 변경할 수 있습니다
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Helm 설치 URL 생성
HELM_URL="https://get.helm.sh/helm-${HELM_VERSION}-${OS}-${ARCH}.tar.gz"

# 다운로드 및 압축 해제
curl -fsSL ${HELM_URL} -o helm.tar.gz
tar -zxvf helm.tar.gz

# Helm 실행 파일을 /usr/local/bin에 이동 (전역적으로 사용 가능하도록)
sudo mv helm-${HELM_VERSION}-${OS}-${ARCH}/helm /usr/local/bin/

# 정리
rm -rf helm-${HELM_VERSION}-${OS}-${ARCH}
rm helm.tar.gz

# 설치 확인
helm version




$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3