sudo sed -i $'/EnvironmentFile=-\/var\/lib\/kubelet/{e echo Environment="KUBELET_EXTRA_ARGS=--node-ip=`ifconfig eth1 | egrep \'inet 192\' | awk \'{print $2}\'`"\n}' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl daemon-reload
sudo systemctl restart kubelet
