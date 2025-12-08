#!/bin/bash

# ==========================================
# 1. Deploy the Private AKS Cluster
# ==========================================
# Ensure you have a Route Table associated with the subnet if using userDefinedRouting
az aks create \
    --name <private-cluster-name> \
    --resource-group <resource-group-name> \
    --vnet-subnet-id <subnet-resource-id> \
    --enable-private-cluster \
    --network-plugin azure \
    --enable-managed-identity \
    --node-count 3 \
    --node-vm-size Standard_DS2_v2 \
    --location eastus \
    --outbound-type userDefinedRouting \
    --disable-public-fqdn

# ==========================================
# 2. Accessing the Cluster (Without VPN)
# ==========================================
# Run kubectl commands directly via the Azure API
az aks command invoke \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --command "kubectl get pods -n kube-system"

# ==========================================
# 3. Login via CLI (With Network Access)
# ==========================================
az login
az account set --subscription <subscription-id>
# Fetch credentials for kubectl
az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>
# Convert to Azure CLI login mode (if using AAD integration)
kubelogin convert-kubeconfig -l azurecli

kubectl get nodes

# ==========================================
# 4. Deploy Internal Load Balancer
# ==========================================
# Make sure internal-lb.yaml is in the current directory
kubectl apply -f internal-lb.yaml

# Verify service creation and IP assignment
kubectl get service internal-lb

# ==========================================
# 5. Create Private DNS Record for App
# ==========================================
# Create the Private DNS Zone (if not exists)
az network private-dns zone create -g <resource-group> -n internal.corp

# Link Zone to VNet
az network private-dns link vnet create \
  -g <resource-group> -n MyDNSLink \
  -z internal.corp -v <vnet-resource-id> -e false

# Add A Record for the Load Balancer IP
# Replace <ILB-Private-IP> with the IP from 'kubectl get service'
az network private-dns record-set a add-record \
  -g <resource-group> -z internal.corp \
  -n app -a <ILB-Private-IP>
