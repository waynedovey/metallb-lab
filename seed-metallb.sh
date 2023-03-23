#!/bin/bash

oc get nodes 2> /dev/null 

if [ $? -eq 0 ]
then
  #oc create namespace metallb-system
  oc new-project metallb-system
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
until oc get MetalLB -n metallb-system | grep metall 2> /dev/null
do
    echo echo "Wait for CRD Installation"
    sleep 30
done

# Show worker nodes IP addresses

oc get node $(oc get nodes | grep worker | grep -v master | awk '{print $1}')  -o wide | awk -v OFS='\t\t' '{print $6}' | grep -v INTERNAL-IP

# Applied all MLB bits

firewall-cmd --add-port=179/tcp
firewall-cmd --add-port=3784/udp
firewall-cmd --add-port=3785/udp
firewall-cmd --runtime-to-permanent

oc apply -f mlb/address-pool-bgp.yaml
oc apply -f mlb/test-bfd-prof.yaml
oc apply -f mlb/peer-test.yaml

# Start BGP Emulator Router

podman run -d --rm  -v /root/metallb-lab/frr:/etc/frr:Z --net=host --name frr-upstream --privileged quay.io/frrouting/frr:master

# Create a test SVC

oc new-project test-metallb
oc create deployment hello-node --image=k8s.gcr.io/e2e-test-images/agnhost:2.33 -- /agnhost serve-hostname

oc create -f mlb/test-frr-svc.yaml


