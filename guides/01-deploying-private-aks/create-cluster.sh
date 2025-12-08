#!/bin/bash

# Create a Private AKS Cluster with Internal Load Balancer support
# Ensure you have a Route Table associated with the subnet if using userDefinedRouting

az aks create \
    --name <private-cluster-name> \
    --resource-group <resource-group-name> \
    --vnet-subnet-id <subnet-resource-id> \
    --enable-private-cluster \
    --network-plugin azure \
    --enable-managed-identity \
    --node-count <node-count> \
    --node-vm-size <sku> \
    --location <region> \
    --outbound-type userDefinedRouting \
    --disable-public-fqdn
