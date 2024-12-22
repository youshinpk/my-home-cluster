# my-home cluster
<img src="./server.jpg" alt="My Image" width="400" height="500">



## 1. 목차
- [소개](#2-소개)
- [정보](#3-정보)
- [운영](#4-운영)
  - [로그 조회](#41-로그-조회)
  - [시작 / 중지 / 재시작](#42-시작-중지-재시작)
  - [인증서 관리](#43-인증서-관리)
  - [업그레이드 관리](#44-업그레이드-관리)
- [백업 및 복구](#5-백업-및-복구)
  - [백업](#51-백업)
  - [복구](#52-복구)
- [트러블슈팅](#6-트러블슈팅)
- [참조](#7-참조)


---

## 2. 소개
이 문서는 나만의 Kubernetes 클러스터 환경에 대해 설명합니다. 이 클러스터는 개인적인 학습과 테스트를 위해 설정되었으며, 다양한 컨테이너화된 애플리케이션을 자유롭게 배포하고 운영할 수 있는 기반을 제공합니다. 이 환경에서는 최신 버전의 Kubernetes를 기반으로 여러 가지 서비스 및 도구를 사용하여 클러스터를 관리하고 모니터링할 수 있습니다.

## 3. 정보

### 3.1 인프라 정보
이 클러스터는 3개의 노드로 구성되어 있습니다. 각 노드는 Ubuntu 22.04 운영 체제를 사용하며, Control Plane 노드는 관리 기능을, Worker 노드들은 애플리케이션 컨테이너를 실행합니다.

| Hostname      | IP            | OS            | CPU   | Memory | Disk  | 
|---------------|---------------|---------------|-------|--------|-------|
| Control Plane | 192.168.1.101 | Ubuntu 22.04  | 4core | 16GB   | 512GB |
| Worker1       | 192.168.1.102 | Ubuntu 22.04  | 4core | 12GB   | 512GB |
| Worker2       | 192.168.1.103 | Ubuntu 22.04  | 4core | 12GB   | 512GB |

### 3.2 Kubernetes 환경 정보
| Initialization  | k8s version | CNI    | CSI             | Tool     | 
|-----------------|-------------|--------|-----------------|----------|
| kubeadm         | 1.29.1      | calico | nfs-provisionor | K9s      |

### 3.3 주요 애플리케이션
이 클러스터에서는 여러 가지 애플리케이션을 Helm을 사용하여 배포하고 운영합니다.

| Name          | Harbor    | Argo CD | Prometheus & Grafana   | Istio    |
|---------------|-----------|---------|------------------------|----------|
| version       | 1.22      | 1.22    | 1.22                   | 1.22     |
| deploy        | helm      | helm    | helm                   | helm     |

---

## 4. 운영

### 4.1 로그 조회
Kubernetes의 각 주요 컴포넌트와 관련된 로그를 확인하여 클러스터의 상태를 모니터링하고 문제를 해결할 수 있습니다.

#### K8s 컴포넌트별 로그 조회

| 로그 조회 대상                      | 명령어                           | 
|----------------------------------|----------------------------------|
| kubelet                         | `journalctl -u kubelet -f`       | 
| kube-apiserver                  | `journalctl -u kube-apiserver -f`|
| kube-controller-manager         | `journalctl -u kube-controller-manager -f` |
| kube-scheduler                  | `journalctl -u kube-scheduler -f`|
| etcd                            | `journalctl -u etcd -f`          |
| coredns                         | `kubectl logs -n kube-system <coredns-pod-name>`|
| calico (CNI)                    | `kubectl logs -n kube-system <calico-pod-name>`|
| nfs-provisioner (CSI)           | `kubectl logs -n kube-system <nfs-provisioner-pod-name>` |
| containerd (CRI)                | `journalctl -u containerd`       |

### 4.2 시작 / 중지 / 재시작
Kubernetes 서비스와 관련된 주요 동작 명령입니다.

| 작업                     | 명령어 |
|--------------------------|--------|
| kubelet 서비스 시작       | `sudo systemctl start kubelet` |
| kubelet 서비스 중지       | `sudo systemctl stop kubelet` |
| kubelet 서비스 재시작     | `sudo systemctl restart kubelet` |

### 4.3 인증서 관리
#### 인증서 갱신 단계

| 단계 | 작업 내용 | 명령어 / 설명 |
|------|----------|---------------|
| **1. 인증서 만료 확인** | 인증서 상태 확인 | - `kubeadm certs check-expiration` <br> 결과를 통해 만료된 인증서를 확인합니다. |
| **2. 인증서 백업** | 기존 인증서 백업 | - 인증서가 저장된 디렉토리 백업: <br> `sudo cp -r /etc/kubernetes/pki /etc/kubernetes/pki.bak` |
| **3. 인증서 갱신** | Control Plane 인증서 갱신 | - `sudo kubeadm certs renew all` <br> 모든 인증서를 갱신합니다. |
| | 특정 인증서 갱신 | - 원하는 인증서만 갱신: <br> 예: `sudo kubeadm certs renew apiserver` |
| | 인증서 갱신 확인 | - `kubeadm certs check-expiration` <br> 갱신된 만료일 확인 |
| **4. Kubelet 인증서 갱신** | Kubelet 구성 갱신 | - kubelet 자동 갱신 확인: <br> `sudo systemctl restart kubelet` |
| **5. 구성 및 Pod 확인** | Control Plane 구성 확인 | - `kubectl get pods -n kube-system` <br> Control Plane Pod 상태를 확인합니다. |
| **6. 인증서 파일 경로** | 주요 인증서 파일 경로 확인 | - `/etc/kubernetes/pki/apiserver.crt` <br> - `/etc/kubernetes/pki/etcd/peer.crt` 등 |
| **7. 주의 사항** | 인증서 갱신 후 클러스터 점검 | - 모든 노드와 Pod의 정상 동작 여부를 확인합니다. |

---

#### 참고 사항

1. **인증서 만료 전 갱신 권장**  
   기본적으로 Kubernetes 인증서는 1년 만료로 설정되므로 주기적으로 만료일을 확인

2. **갱신 후 재배포 필요 여부 확인**  
   인증서를 갱신한 후, 일부 서비스가 갱신된 인증서를 인식하도록 재배포가 필요여부 확인이 필요

3. **etcd 인증서 관리**  
   etcd 관련 인증서의 경우 별도로 갱신해야 할 수도 있음 `/etc/kubernetes/pki/etcd` 디렉토


### 4.4 업그레이드 관리

#### kubeadm을 이용한 버전 업그레이드

| 단계 | 작업 내용 | 명령어 / 설명 |
|------|----------|---------------|
| **1. 클러스터 상태 확인** | 현재 상태 확인 | - `kubectl version --short` <br> - `kubectl get nodes` <br> - `kubectl get pods -A` |
| **2. 업그레이드 계획 확인** | 업그레이드 가능한 버전 확인 | - `kubeadm upgrade plan` |
| **3. Control Plane 업그레이드** | kubeadm 패키지 업그레이드 | - `sudo apt update` <br> - `sudo apt install -y kubeadm` <br> - `kubeadm version` |
| | Control Plane 구성 업그레이드 | - `sudo kubeadm upgrade apply <target-version>` <br> 예: `sudo kubeadm upgrade apply v1.29.3` |
| | kubelet 및 kubectl 업그레이드 | - `sudo apt install -y kubelet kubectl` <br> - `sudo systemctl restart kubelet` |
| | 업그레이드 확인 | - `kubectl get nodes` |
| **4. Worker 노드 업그레이드** | kubeadm 패키지 업그레이드 | - `sudo apt update` <br> - `sudo apt install -y kubeadm` |
| | 노드 구성 업그레이드 | - `sudo kubeadm upgrade node` |
| | kubelet 및 kubectl 업그레이드 | - `sudo apt install -y kubelet kubectl` <br> - `sudo systemctl restart kubelet` |
| | 업그레이드 확인 | - `kubectl get nodes` |
| **5. 애플리케이션 및 네트워크 플러그인 확인** | 애플리케이션 확인 | - `kubectl get pods -A` |
| | 네트워크 플러그인 확인 및 재배포 | 필요 시 최신 버전으로 재배포 |
| **6. 주의 사항** | 백업 | - etcd 스냅샷 백업: <br> `etcdctl snapshot save <backup-file-path>` |
| | 버전 호환성 확인 | Kubernetes 공식 문서에서 확인 |

#### 참고 사항
- 업그레이드 전에 반드시 **클러스터의 백업**을 수행
- 업그레이드 작업은 Control Plane부터 시작하여 Worker 노드를 순차적으로 진행
- Kubernetes의 [공식 문서](https://kubernetes.io/docs/)를 참고하여 호환성과 업그레이드 절차를 확인필수


## 5. 백업 및 복구
###  5.1 백업
etcd는 클러스터의 상태를 관리하는 중요한 구성 요소로, 주기적인 백업이 필요합니다. 아래 명령어를 사용하여 즉시 백업을 수행할 수 있습니다.

```bash
etcdctl snapshot save <backup-file-path>
etcdctl snapshot status <backup-file-path>
```
### 5.2 복구
백업한 etcd 데이터를 복구하려면 아래 명령어를 사용합니다.

```bash
ETCDCTL_API=3 etcdctl snapshot restore <backup-file-path> --data-dir /var/lib/etcd
```

## 6. 트러블슈팅
Kubernetes 클러스터에서 발생할 수 있는 일반적인 문제를 해결하는 방법에 대해 다룹니다.

### 6.1 일반적인 문제 해결 방법
Pod가 스케줄되지 않는 경우:
```kubectl describe pod <pod-name>``` 명령어로 에러 메시지를 확인합니다.

네트워크 문제: CNI 플러그인의 로그 및 네트워크 설정을 점검합니다.
### 6.2 서비스 문제 해결
서비스가 시작되지 않는 경우: ```kubectl get pods -n kube-system``` 명령어로 상태를 확인하고, 관련 로그를 확인합니다.

## 7. 참조
Kubernetes 공식 문서
Harbor for Private Docker Registry
K9s 공식 문서