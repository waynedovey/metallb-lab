#!/bin/bash

oc get nodes 2> /dev/null 

if [ $? -eq 0 ]
then
  oc create namespace metallb-system
  oc project metallb-system
  oc create -f operator/operator-group.yaml
  oc create -f operator/mlb-operator-subscription.yaml
else
  echo "Login into the OpenShift Cluster" >&2
  exit 1
fi

# Check progress of the Operator
until oc get csv -n metallb-system | grep Succeeded 2> /dev/null
do
    echo echo "Wait for Operator Installation"
    sleep 10
done

# Create the CRD
oc create -f operator/custom-resource.yaml
until oc get mch -n metallb-system | grep Running 2> /dev/null
do
    echo echo "Wait for CRD Installation"
    sleep 30
done

# Applied all MLB bits

oc apply -f mlb/address-pool-bgp.yaml
oc apply -f mlb/test-bfd-prof.yaml
oc apply -f mlb/peer-test.yaml

# Start BGP Emulator Router

podman run -d --rm  -v /root/metallb-lab/frr:/etc/frr:Z --net=host --name frr-upstream --privileged quay.io/frrouting/frr:master


