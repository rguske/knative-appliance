#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

# Setup Docker and Kubernetes

set -euo pipefail

BOM_FILE=/root/config/bom.json

echo -e "\e[92mStarting Docker ..." > /dev/console
systemctl daemon-reload
systemctl start docker.service
systemctl enable docker.service

echo -e "\e[92mDisabling/Stopping IP Tables  ..." > /dev/console
systemctl stop iptables
systemctl disable iptables

# Customize the POD CIDR Network if provided or else default to 10.10.0.0/16
if [ -z "${POD_NETWORK_CIDR}" ]; then
    POD_NETWORK_CIDR="10.16.0.0/16"
fi

# Setup k8s
echo -e "\e[92mSetting up k8s ..." > /dev/console
K8S_VERSION=$(jq -r < ${BOM_FILE} '.["kubernetes"].gitRepoTag')
cat > /root/config/kubeconfig.yml << __EOF__
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: ${K8S_VERSION}
networking:
  podSubnet: ${POD_NETWORK_CIDR}
__EOF__

echo -e "\e[92mDeloying kubeadm ..." > /dev/console
HOME=/root
kubeadm init --ignore-preflight-errors SystemVerification --skip-token-print --config /root/config/kubeconfig.yml
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl taint nodes --all node-role.kubernetes.io/master-

echo -e "\e[92mDeloying Antrea ..." > /dev/console
kubectl apply -f /root/download/antrea.yml

echo -e "\e[92mStarting k8s ..." > /dev/console
systemctl enable kubelet.service

while [[ $(systemctl is-active kubelet.service) == "inactive" ]]
do
    echo -e "\e[92mk8s service is still inactive, sleeping for 10secs" > /dev/console
    sleep 10
done

echo -e "\e[92mDeploying Local Storage Provisioner ..." > /dev/console
mkdir -p ${LOCAL_STOARGE_VOLUME_PATH}/local-path-provisioner
chmod 777 ${LOCAL_STOARGE_VOLUME_PATH}/local-path-provisioner
kubectl apply -f /root/download/local-path-storage.yaml
kubectl patch sc local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo -e "\e[92mCreating VMware namespaces ..." > /dev/console
kubectl create namespace vmware-system
kubectl create namespace vmware-functions