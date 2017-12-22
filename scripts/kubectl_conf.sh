#!/bin/bash

CONF_DIR='../conf'
PKI_DIR='../pki'

check_cluster=$( kubectl config get-contexts  | awk 'NR>1 {print $3}' | egrep '^kubernetes$' )
if [ "$check_cluster" != "kubernetes" ]; then
echo "Generating the configuration for kubectl"
kubectl config set-cluster kubernetes \
  --certificate-authority=$PKI_DIR/ca.pem \
  --embed-certs=true \
  --server=https://10.0.0.100:6443

kubectl config set-credentials admin \
  --client-certificate=$PKI_DIR/admin.pem \
  --client-key=$PKI_DIR/admin-key.pem

kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin

kubectl config use-context kubernetes
fi

if [[ ! -d $CONF_DIR ]] && [[ ! -f $CONF_DIR/k8s-worker1.kubeconfig ]] && [[ ! -f $CONF_DIR/k8s-worker2.kubeconfig ]] && [[ ! -f $CONF_DIR/k8s-worker3.kubeconfig ]]
then
echo "Generating the configuration for workers"

mkdir $CONF_DIR

for instance in k8s-worker1 k8s-worker2 k8s-worker3; do
  kubectl config set-cluster kubernetes \
    --certificate-authority=$PKI_DIR/ca.pem \
    --embed-certs=true \
    --server=https://10.0.0.100:6443 \
    --kubeconfig=$CONF_DIR/${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=$PKI_DIR/${instance}.pem \
    --client-key=$PKI_DIR/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=$CONF_DIR/${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes \
    --user=system:node:${instance} \
    --kubeconfig=$CONF_DIR/${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=$CONF_DIR/${instance}.kubeconfig
done
fi

if [ ! -f $CONF_DIR/kube-proxy.kubeconfig ]; then

echo "Generating the configuration for kube-proxy"

kubectl config set-cluster kubernetes \
  --certificate-authority=$PKI_DIR/ca.pem \
  --embed-certs=true \
  --server=https://10.0.0.100:6443 \
  --kubeconfig=$CONF_DIR/kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=$PKI_DIR/kube-proxy.pem \
  --client-key=$PKI_DIR/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=$CONF_DIR/kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=$CONF_DIR/kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=$CONF_DIR/kube-proxy.kubeconfig
fi
