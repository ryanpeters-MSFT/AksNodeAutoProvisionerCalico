$GROUP = "rg-aks-nap-calico-byo"
$CLUSTER = "napcalicocluster"

# create the resource group
az group create --name $GROUP --location eastus2

# create the cluster with BYO CNI
az aks create -n $CLUSTER -g $GROUP `
    --node-provisioning-mode auto `
    --os-sku AzureLinux `
    -c 1 `
    --pod-cidr 10.5.0.0/16 `
    --network-plugin none

# get the credentials
az aks get-credentials -n $CLUSTER -g $GROUP --overwrite-existing

# install the calico operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml

# configure the calico installation
kubectl apply -f .\installation.yaml