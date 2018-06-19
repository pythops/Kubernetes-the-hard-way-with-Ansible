[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Introduction
This is an attempt to automate the creation of k8s cluster proposed in the tutorial [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

<p align="center">
<img src="docs/architecture.png" width="550px">
</p>

## Cluster details
* k8s version: **1.10.2**
* Container runtime: [Docker](https://www.docker.com/)
* Network plugin: [Flannel](https://github.com/coreos/flannel)
* DNS plugin: [CoreDNS](https://github.com/coredns/coredns)
* [gVisor](https://github.com/google/gvisor) supported.

## Prerequisites
Before you begin, you need to install all these tools:
- [Ansible](https://www.ansible.com/)
- [cfssl](https://github.com/cloudflare/cfssl)
- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

You need also to have at least 4 GB of free memory.
## How to use

Create the VMs with Vagrant
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
k8s-worker1   Ready     <none>    19s       v1.10.2
k8s-worker2   Ready     <none>    20s       v1.10.2
k8s-worker3   Ready     <none>    20s       v1.10.2

```

*Check DNS add-on*
```
$ kubectl get pod -l k8s-app=coredns -n kube-system
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
$ kubectl -n kube-system get service kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.32.0.63   <none>        443:30585/TCP   23m
```

The Dashbord is accessible at `https://<Worker-IP>:30585`

To log in, select Token and insert the token given by the following command:

```
$ kubectl describe serviceaccount kubernetes-dashboard -n kube-system | grep Tokens | awk '{print $2}' | xargs kubectl -n kube-system describe secret  | grep '^token' | awk -F ':' '{print $2}'
```

*Check the monitoring pods*
```
$ kubectl get pods  -l task=monitoring --all-namespaces
NAMESPACE     NAME                                   READY     STATUS    RESTARTS   AGE
kube-system   heapster-69b5d4974d-kxgjw              1/1       Running   0          2m
kube-system   monitoring-grafana-69df66f668-m59hp    1/1       Running   0          2m
kube-system   monitoring-influxdb-78d4c6f5b6-gh56w   1/1       Running   0          2m
```

*Access Grafana*

Get the port on which grafana is exposed:
```
$ kubectl -n kube-system get service monitoring-grafana  
NAME                 TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
monitoring-grafana   NodePort   10.32.0.238   <none>        80:31244/TCP   7m
```

the dashboard is accessible at `http://<Worker-IP>:31244`

## License
The source code in this repo is licenced under the GPL 3
