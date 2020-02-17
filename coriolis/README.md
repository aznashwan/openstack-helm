# Deployment quickstart

## Prerequisites:

NOTE: pre-creates KubeADM-administered cluster:

```bash
# Clone git repos:
git clone https://opendev.org/openstack/openstack-helm-infra.git
git clone https://opendev.org/openstack/openstack-helm.git

# Optional (change default DNS for cluster):
# edit 'external_dns_nameservers' in:
# openstack-helm-infra/tools/images/kubeadm-aio/assets/opt/playbooks/vars.yaml

# Deploy Kubernetes:
./tools/deployment/developer/common/010-deploy-k8s.sh
```

## Client setup and chart assembly:

```bash
# Setup clients:
./tools/deployment/developer/common/020-setup-client.sh

# Deploy ingress controller:
./tools/deployment/component/common/ingress.sh
```


## Deploy supporting services:

``` bash
# MariaDB:
./tools/deployment/developer/nfs/050-mariadb.sh

# RabbitMQ:
./tools/deployment/developer/nfs/060-rabbitmq.sh

# Memcached:
./tools/deployment/developer/nfs/070-memcached.sh

# Keystone:
./tools/deployment/developer/nfs/080-keystone.sh
```


## Deploy Coriolis:

```bash

# TODO:

```


## Cleanup:

```bash

# WARN: this will clean up everything!!!
for NS in openstack ceph nfs libvirt; do
   helm ls --namespace $NS --short | xargs -r -L1 -P2 helm delete --purge
done

sudo systemctl stop kubelet
sudo systemctl disable kubelet

sudo docker ps -aq | xargs -r -L1 -P16 sudo docker rm -f

sudo rm -rf /var/lib/openstack-helm/*

# NOTE(portdirect): These directories are used by nova and libvirt
sudo rm -rf /var/lib/nova/*
sudo rm -rf /var/lib/libvirt/*
sudo rm -rf /etc/libvirt/qemu/*

# NOTE(portdirect): Clean up mounts left behind by kubernetes pods
sudo findmnt --raw | awk '/^\/var\/lib\/kubelet\/pods/ { print $1 }' | xargs -r -L1 -P16 sudo umount -f -l

```
