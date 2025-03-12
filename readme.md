# AKS Node Autoprovisioning with Calico (BYO CNI)

This repository demonstrates the ability to deploy Calico on an AKS cluster with Node Autoprovisioning (aka, Karpenter). It's important to note that this is NOT the managed installation (e.g, using `--network-policy calico` during `az aks create`). 

**This also means that because it is using BYO CNI, it is [not supported by Microsoft](https://learn.microsoft.com/en-us/azure/aks/use-byo-cni?tabs=azure-cli).**

## Quickstart

The scripts below will create a deployment and service to a namespace called `apps`, along with two "client" pods: `client1` and `client2`. The network policy ([networkpolicy.yaml](./networkpolicy.yaml)) only allows ingress traffic to the nginx pods from `client1` (via matching pod labels `run=client1`). It will deny traffic from `client2`. 

```powershell
# create an apps namespace
kubectl create ns apps

# deploy the workloads and a simple calico network policy
kubectl apply -n apps -f .\workload.yaml -f .\networkpolicy.yaml

# view/verify the network policy
kubectl get caliconetworkpolicies -n apps

# curl into "client1" pod and curl to the nginx service endpoint (200 response)
kubectl exec -n apps -it client1 -- curl http://nginx

# curl into "client2" pod and curl to the nginx service endpoint (timeout)
kubectl exec -n apps -it client2 -- curl http://nginx
```

## Optional: Verify NAP/Karpenter Node Scaling

The deployment above does not contain any resource requests/limits, so you will most-likely not see any node scaling. To verify that the default `NodePool` functionality exists, update the [workload.yaml](./workload.yaml) to include high CPU and memory requests as well as additional replicas. Once re-deployed, this will trigger a scale-up of the nodes and `NodeClaim` objects due to the nginx pods being in a `Pending` state. 