# !/bin/bash
set -eux

# Habilitar IP forwarding (para flannel/calico)
echo "net.bridge.bridge-nf-call-iptables=1" >>/etc/sysctl.conf

# 🟢 Cargar el módulo necesario
modprobe br_netfilter
sysctl -p

# Desactivar swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Requisitos
apt-get update
apt-get install -y curl apt-transport-https ca-certificates gnupg lsb-release

# Repositorio de Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" >/etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl containerd
apt-mark hold kubelet kubeadm kubectl

# Configurar containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Habilitar SSH con password
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh
