## Introduction

This is an attempt to automate the creation of k8s cluster proposed in the tutorial [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

<p align="center">
<img src="docs/architecture.png" width="550px">
</p>
## Prerequisites
Before you begin, you need to install all these tools:
- [Ansible](https://www.ansible.com/)
- [cfssl](https://github.com/cloudflare/cfssl)
- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

You need also to have at least 4 GB of free memory.
## How to use

Bootstrap the VMs with Vagrant
```
$ vagrant up
```

Deploy k8s cluster
```
$ ansible-playbook k8s.yml
```
## Verification
*Check the k8s master's components*
```
$ kubectl get componentstatus
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok                   
scheduler            Healthy   ok                   
etcd-2               Healthy   {"health": "true"}   
etcd-0               Healthy   {"health": "true"}   
etcd-1               Healthy   {"health": "true"}   
```

*Check the k8s workers*
```
$ kubectl get nodes
NAME          STATUS    ROLES     AGE       VERSION
k8s-worker1   Ready     <none>    5m        v1.8.0
k8s-worker2   Ready     <none>    5m        v1.8.0
k8s-worker3   Ready     <none>    5m        v1.8.0

```

*Check DNS add-on*
```
$ kubectl get pod -n kube-system
NAME                      READY     STATUS    RESTARTS   AGE
coredns-b8d4b46c8-t2zpf   1/1       Running   0          37m
```

*Check Dashboard*
```
$ kubectl get pod -l k8s-app=kubernetes-dashboard -n kube-system
NAME                                    READY     STATUS    RESTARTS   AGE
kubernetes-dashboard-7c5d596d8c-vp85k   1/1       Running   0          8m
```

*Accessing Dashboard*

Get the port on which the dashbord is exposed
```
$ kubectl -n kube-system get service kubernetes-dashboard                                                                                               1 ↵
NAME                   TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.32.0.63   <none>        443:30585/TCP   23m
```

The Dashbord is accessible at `https://<Worker-IP>:30585`

## Roadmap
- [x] PKI
- [x] Etcd cluster
- [x] k8s masters
- [x] Loadbalancer
- [x] k8s workers
- [x] Flannel
- [x] CoreDNS
- [x] Dashboard
- [ ] Smoke Test
- [ ] PKI with Ansible openssl module

## Issues
* Flannel: Can not use API server to set the network configuration.
https://github.com/coreos/flannel/issues/792
* Ansible openssl: Does not support CA certificate option.
https://docs.ansible.com/ansible/2.4/openssl_csr_module.html

## License
The source code in this repo is licenced under the GPL 3
