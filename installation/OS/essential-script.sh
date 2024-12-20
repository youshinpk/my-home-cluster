sudo apt update
sudo apt install vim git curl wget net-tools openssh-server

#1. Swap 비활성화
# swap 상태 확인
sudo swapon --show

# swap 비활성화
sudo swapoff -a

# 시스템 재부팅 시에도 swap이 비활성화되도록 설정
sudo sed -i '/swap/d' /etc/fstab

#2. iptables 설정 ------------------------------------------------------------
#Kubernetes는 iptables를 사용하여 네트워크 트래픽을 관리합니다. iptables를 사용하는 것을 방해하는 설정을 피하기 위해 br_netfilter 모듈을 활성화해야 합니다.

# `br_netfilter` 모듈을 로드
sudo modprobe br_netfilter

# `br_netfilter` 모듈을 항상 로드되도록 설정
echo "br_netfilter" | sudo tee -a /etc/modules-load.d/k8s.conf

# iptables가 올바르게 동작하도록 시스템의 `net.bridge` 설정을 변경
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo sysctl net.bridge.bridge-nf-call-ip6tables=1

# sysctl 설정을 영구적으로 적용
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p


