# 시스템 업데이트 및 필수 패키지 설치
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# 스왑 비활성화
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 방화벽 전체 오픈
## Kubernetes API
sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT

## etcd
sudo iptables -A INPUT -p tcp --dport 2379:2380 -j ACCEPT

## Kubelet
sudo iptables -A INPUT -p tcp --dport 10250:10255 -j ACCEPT

## NodePort 서비스
sudo iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT

## 네트워크 플러그인
sudo iptables -A INPUT -p udp --dport 4789 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT

sudo iptables-save > /etc/iptables/rules.v4

# 네트워크 설정
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Container runtime 설치
sudo apt-get install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# kubernetes 설치 (kubeadm)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Worker node init 진행
kubeadm join 192.168.0.101:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>

