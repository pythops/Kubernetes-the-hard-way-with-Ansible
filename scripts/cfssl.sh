#!/bin/bash


PKI_DIR="../pki"

if [ ! -d $PKI_DIR ]; then
mkdir $PKI_DIR
fi

if [ ! -f $PKI_DIR/ca-key.pem ] && [ ! -f $PKI_DIR/ca.pem ]; then

echo "Generating CA certificate"

cat > $PKI_DIR/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > $PKI_DIR/ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Paris",
      "O": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert -initca $PKI_DIR/ca-csr.json | cfssljson -bare $PKI_DIR/ca
fi


if [ ! -f $PKI_DIR/admin.pem ] && [ ! -f $PKI_DIR/amin-key.pem ]; then

echo "Generating admin certificate"

cat > $PKI_DIR/admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Paris",
      "O": "system:masters"
    }
  ]
}
EOF

cfssl gencert \
  -ca=$PKI_DIR/ca.pem \
  -ca-key=$PKI_DIR/ca-key.pem \
  -config=$PKI_DIR/ca-config.json \
  -profile=kubernetes \
  $PKI_DIR/admin-csr.json | cfssljson -bare $PKI_DIR/admin

fi

if [ ! -f $PKI_DIR/k8s-master.pem ] && [ ! -f $PKI_DIR/k8s-master-key.pem ]; then

echo "Generating k8s master certificate"

cat > $PKI_DIR/kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Paris",
      "O": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=$PKI_DIR/ca.pem \
  -ca-key=$PKI_DIR/ca-key.pem \
  -config=$PKI_DIR/ca-config.json \
  -hostname=10.0.0.100,10.0.0.101,10.0.0.102,10.0.0.103,127.0.0.1,10.32.0.1,10.32.0.10,kubernetes.default \
  -profile=kubernetes \
  $PKI_DIR/kubernetes-csr.json | cfssljson -bare $PKI_DIR/k8s-master

fi

if [[ ! -f $PKI_DIR/k8s-worker1.pem ]] && [[ ! -f $PKI_DIR/k8s-worker1-key.pem ]]; then

echo "Generating worker cerificates"

for instance in k8s-worker1 k8s-worker2 k8s-worker3; do
cat > $PKI_DIR/${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Paris",
      "O": "system:nodes"
    }
  ]
}
EOF

if [ "$instance" == "k8s-worker1" ]; then
	IP=10.0.0.110
elif [ "$instance" == "k8s-worker2" ]; then
	IP=10.0.0.111
else
	IP=10.0.0.112
fi

cfssl gencert \
  -ca=$PKI_DIR/ca.pem \
  -ca-key=$PKI_DIR/ca-key.pem \
  -config=$PKI_DIR/ca-config.json \
  -hostname=${instance},${IP} \
  -profile=kubernetes \
  $PKI_DIR/${instance}-csr.json | cfssljson -bare $PKI_DIR/${instance}
done
fi

if [ ! -f $PKI_DIR/kube-proxy.pem ] && [ ! -f $PKI_DIR/kube-proxy-key.pem ]; then
echo "Generating proxy certificates"

cat > $PKI_DIR/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Paris",
      "O": "system:node-proxier"
    }
  ]
}
EOF

cfssl gencert \
  -ca=$PKI_DIR/ca.pem \
  -ca-key=$PKI_DIR/ca-key.pem \
  -config=$PKI_DIR/ca-config.json \
  -profile=kubernetes \
  $PKI_DIR/kube-proxy-csr.json | cfssljson -bare $PKI_DIR/kube-proxy
fi

if [ ! -f $PKI_DIR/encryption-config.yml ]; then
echo "Generating encryption key"
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
cat > $PKI_DIR/encryption-config.yml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
fi

rm -f $PKI_DIR/*csr* 
