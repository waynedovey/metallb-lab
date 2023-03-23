# Introduction

This project enables a working MetalLB Enviornment to use with OpenShift 4.10+

## Check out the Repo

```
git clone https://github.com/waynedovey/metallb-lab.git
```
```
cd metallb-lab
```

## Update the Load Balancer address Pool

The example Range can be adjusted to match the network requirements

```
  addresses:
  - 192.168.155.150/32
  - 192.168.155.151/32
  - 192.168.155.152/32
  - 192.168.155.153/32
  - 192.168.155.154/32
  - 192.168.155.155/32
```  

Edit file mlb/address-pool-bgp.yaml

## Adjust the BGP Local, Peer ASN and BGP Router address

```
  myASN: 64520
  peerASN: 64521
  peerAddress: 192.168.1.1
```  

Edit file mlb/peer-test.yaml

## Run the seed script to start the installation

./seed-metallb.sh