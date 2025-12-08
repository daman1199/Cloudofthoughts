#!/bin/bash

# ==========================================
# Common Kubectl Commands for AKS Management
# ==========================================

# --- 1. Basic Cluster Status ---
kubectl get nodes                   # List all nodes
kubectl get nodes -o wide           # List nodes with IP details
kubectl describe node <node-name>   # Detailed info about a specific node

# --- 2. Pod Management ---
kubectl get pods -A                 # List pods in ALL namespaces
kubectl get pods -n <namespace>     # List pods in a specific namespace
kubectl describe pod <pod-name>     # Debug a specific pod (check events/errors)
kubectl logs <pod-name>             # View logs for a pod
kubectl delete pod <pod-name>       # Delete (restart) a pod

# --- 3. Deployments & Services ---
kubectl get deployments             # List deployments
kubectl get svc                     # List services (check EXTERNAL-IP here)
kubectl describe svc <svc-name>     # Debug service (check Endpoints)
kubectl apply -f <file.yaml>        # Apply a manifest file

# --- 4. Networking Debugging ---
kubectl get endpoints               # Check if your Service is targeting any Pods
kubectl get ingress                 # List Ingress resources

# ==========================================
# AKS Command Invoke (No VPN Access)
# ==========================================
# Use these when you cannot connect directly to the private cluster API.

# Check nodes
az aks command invoke \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --command "kubectl get nodes"

# Check pods in kube-system (core components)
az aks command invoke \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --command "kubectl get pods -n kube-system"

# Check services
az aks command invoke \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --command "kubectl get svc --all-namespaces"

# Describe a specific pod (useful for debugging failures)
az aks command invoke \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --command "kubectl describe pod <pod-name> -n <namespace>"
