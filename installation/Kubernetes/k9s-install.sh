K9S_VERSION="v0.27.0"  # 원하는 k9s 버전으로 변경 가능
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# k9s 설치 URL 생성
K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_${K9S_VERSION}_${OS}_${ARCH}.tar.gz"

# k9s 다운로드 및 압축 해제
curl -fsSL ${K9S_URL} -o k9s.tar.gz
tar -zxvf k9s.tar.gz

# k9s 바이너리 이동
sudo mv k9s_${K9S_VERSION}_${OS}_${ARCH}/k9s /usr/local/bin/

# 정리
rm -rf k9s_${K9S_VERSION}_${OS}_${ARCH}
rm k9s.tar.gz

# 설치 확인
k9s version



ㅁㄴㅇㅁㄴㅇㅁㄴㅁㄴㅇㅁㄴㅇ