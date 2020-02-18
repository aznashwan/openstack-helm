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

# Create secret with Coriolis reg creds:
kubectl create secret docker-registry cbslreg \
    --namespace=openstack \
    --docker-server=<your-registry-server> \
    --docker-username=<your-name> \
    --docker-password=<your-pword> \
    --docker-email=<your-email>
```

## Client setup and chart assembly:

```bash
# Setup openstack clients:
./tools/deployment/developer/common/020-setup-client.sh

# Setup Coriolis client:
# NOTE: requires Python 3:
sudo apt install -y python3-dev python3-pip
sudo pip3 install --upgrade --force-reinstall git+https://github.com/cloudbase/python-coriolisclient.git

# Deploy ingress controller:
./tools/deployment/component/common/ingress.sh
```


## Deploy supporting services:

``` bash
# NOTE: A storage provisioner is required for providing some pv
# storage class. All further charts/scripts expect there to be
# a storage class named 'general'.
# One may switch out to using Ceph by using the scripts found
# in ./tools/deployment/developer/ceph instead of these ones.
./tools/deployment/developer/nfs/040-nfs-provisioner.sh

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

#!/bin/bash
set -xe

#NOTE: Lint and package chart
make coriolis

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_CORIOLIS:="$(./tools/deployment/common/get-values-overrides.sh coriolis)"}

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install coriolis ./coriolis \
    --namespace=openstack \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_CORIOLIS}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status coriolis

#NOTE: doesn't yet work, need to export all the individual props:
export OS_CLOUD=openstack_helm
export OS_USERNAME='admin'
export OS_PASSWORD='password'
export OS_PROJECT_NAME='admin'
export OS_PROJECT_DOMAIN_NAME='default'
export OS_USER_DOMAIN_NAME='default'
export OS_AUTH_URL='http://keystone.openstack.svc.cluster.local/v3'

sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
coriolis migration list
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
