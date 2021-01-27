sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


## DISABLE SWAP
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# (Install Docker CE)
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update && sudo apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2

# Add Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

# Add the Docker apt repository:
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# Install Docker CE
sudo apt-get update && sudo apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)

# Set up the Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Create /etc/systemd/system/docker.service.d
sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo systemctl enable docker

sudo apt-get install ipvsadm -y

sudo sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
sudo sysctl -f

#sudo kubeadm init --feature-gates "IPv6DualStack=true" --feature-gates "SupportIPVSProxyMode=true" --pod-network-cidr 10.244.0.0/16,fc00::/56 --apiserver-advertise-address 192.168.4.11 --service-cidr 10.96.0.0/12,fc01::/108
#sudo kubeadm init --feature-gates "IPv6DualStack=true" --pod-network-cidr 10.244.0.0/16,fc00::/56 --apiserver-advertise-address 192.168.4.11 --service-cidr 10.96.0.0/12,fc01::/108

sudo bash -c 'cat << EOF > /vagrant/kubeadm-new.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.4.11
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta2
Kind: ClusterConfiguration
apiServer:
  certSANs:
  - "192.168.4.11"
  - "10.96.0.1"
  - "127.0.0.1"
  - "kubernetes.1dco.com"
  - "kubernetes.cluster.local"
  extraArgs:
    advertise-address: "192.168.4.11"
    authorization-mode: "Node,RBAC"
  timeoutForControlPlane: 4m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager:
  extraArgs:
    bind-address: "192.168.4.11"
dns:
  type: CoreDNS
etcd:
  local:
    serverCertSANs:
    - "192.168.4.11"
    - "10.96.0.1"
    - "127.0.0.1"
    peerCertSANs:
    - "192.168.4.11"
    - "10.96.0.1"
    - "127.0.0.1"
    extraArgs:
      listen-peer-urls: "https://192.168.4.11:2380"
      listen-client-urls: "https://192.168.4.11:2379"
      advertise-client-urls: "https://192.168.4.11:2379"
      initial-advertise-peer-urls: "https://192.168.4.11:2380"
      listen-metrics-urls: "http://192.168.4.11:2381"
featureGates:
  IPv6DualStack: true
kubeProxy:
  config:
    featureGates:
      SupportIPVSProxyMode: true
    mode: "ipvs"
imageRepository: k8s.gcr.io
kubernetesVersion: v1.20.2
networking:
  dnsDomain: cluster.local
  podSubnet: "10.244.0.0/16,fc00::/56"
  serviceSubnet: "10.96.0.0/12,fc01::/108"
scheduler:
  extraArgs:
    address: "192.168.4.11"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF'
sudo kubeadm init --config=/vagrant/kubeadm-new.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

sudo kubeadm token list
sudo apt install net-tools -y
sudo apt install tcptraceroute traceroute -y


openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1

TOKEN=$(sudo kubeadm token list | grep -v TOKEN | awk '{print $1}')
SHA=$(openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)

echo "sudo kubeadm join 192.168.4.11:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$SHA" > /home/vagrant/kubejoin.sh

curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -

sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

sudo sed -i $'/EnvironmentFile=-\/var\/lib\/kubelet/{e echo Environment="KUBELET_EXTRA_ARGS=--node-ip=`ifconfig eth1 | egrep \'inet 192\' | awk \'{print $2}\'`"\n}' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl daemon-reload
sudo systemctl restart kubelet

sudo cp /home/vagrant/kubejoin.sh /vagrant/kubejoin.sh
sudo chmod +x /vagrant/kubejoin.sh

sudo systemctl restart kubelet

kubectl apply -f /vagrant/calico.yaml
