---
layout: page
title: "Hybrid DNS Resolution"
permalink: /engineer-handbook/03-hybrid-dns-resolution/
tags: [azure, networking, dns]
status: published
type: handbook
date: 2025-12-05
summary: "Understanding how Private Endpoints, Private DNS Zones, and the Azure Private DNS Resolver enable seamless hybrid connectivity."
---

*Understanding how Private Endpoints, Private DNS Zones, and the Azure Private DNS Resolver enable seamless hybrid connectivity.*

| Date | Category |
|------|----------|
| 2025-12-05 | Networking |


---

> **TL;DR:** On-premise users can't reach Azure Private Endpoints because Private DNS Zones only exist inside Azure. Solution: Deploy an **Azure Private DNS Resolver** in your Hub VNet, configure **conditional forwarders** on-prem to point to it, and it will resolve private IPs for you.

---

## Prerequisites
Before attempting to implement Hybrid DNS, you must have the networking foundation in place:
1.  **Hybrid Connectivity:** An active **Site-to-Site VPN** or **ExpressRoute** circuit connecting On-Premises to Azure.
2.  **Hub & Spoke Topology:** A central Hub VNet (or vWAN Hub) where shared services live, appearing as the "entry point" from on-prem.
3.  **Permissions:** `Network Contributor` (or higher) to create VNet Links and DNS Zones.


---

## Architecture Overview

Before diving into the technical components, let's walk through what actually happens when an on-premise user tries to access a private Azure resource.

### The Request Flow (High-Level)
1.  **User initiates request:** An on-premise user tries to access an Azure resource (e.g., `myacr.azurecr.io`).
2.  **DNS lookup:** The request hits the local DNS server, which has a **conditional forwarder** pointing to the Azure Private DNS Resolver's inbound endpoint.
3.  **VPN/ExpressRoute:** The DNS query travels over the site-to-site VPN (or ExpressRoute) to Azure.
4.  **Azure DNS Resolver:** The Private DNS Resolver receives the query and forwards it to Azure DNS, which checks the linked Private DNS Zones.
5.  **Private DNS Zone lookup:** The Private DNS Zone (e.g., `privatelink.azurecr.io`) returns the **private IP** of the resource's Private Endpoint.
6.  **Firewall validation:** If firewall/NSG rules permit the traffic, the user can connect to the resource.

### Security Layers (Low-Level)
*   **Private Endpoints:** All Azure resources are fronted by Private Endpoints (no public IPs).
*   **vWAN Hub:** Traffic flows through a secured Virtual WAN Hub containing the site-to-site VPN and Azure Firewall.
*   **Firewall/NSG Rules:** Access is controlled at the network layer (e.g., allow port 5432 for PostgreSQL, port 443 for Blob Storage).
*   **Public Access Disabled:** The Azure resources themselves have public network access completely disabled.

---

## 1. The Core Components

### A. Private Endpoint
A network interface in your VNet that gives an Azure PaaS service (e.g., ACR, Web App) a private IP from your subnet.
*   **Problem:** It's just an IP. Humans need names.

### B. Private DNS Zone
An Azure-hosted DNS zone (e.g., `privatelink.azurecr.io`) that maps friendly names to private IPs.
*   **Requirement:** Your VNet must be **linked** to the zone to resolve names.
*   **Analogy:** Think of a Private DNS Zone like a corporate **phone book**. Creating the book isn't enough; you physically have to give a copy of it to your office (the **Virtual Network Link**) before the employees inside can look up any numbers. Without the link, the VNet doesn't know the zone exists.

---

## 2. The Hybrid Problem

Everything works great inside Azure. If your VM is in the same VNet (or a peered VNet linked to the DNS Zone), it resolves the name correctly.

**The issue arises when you are On-Premises (via VPN/ExpressRoute):**
1.  You try to ping `myacr.azurecr.io`.
2.  Your on-prem DNS server asks public DNS (Google/Cloudflare).
3.  Public DNS returns the **Public IP** of the service.
4.  **Result:** Connection blocked (because we disabled public access!).

**Why?** On-prem DNS can't see Azure Private DNS Zones—they only exist inside Azure's network.

---

## 3. The Solution: Azure Private DNS Resolver

To bridge this gap, we need a "middleman" inside Azure that *can* see the Private DNS Zones and is reachable from On-Premises.

### How it Works
1.  **Deploy:** You deploy an **Azure Private DNS Resolver** into a dedicated subnet in your Hub VNet (or vWAN Hub).
2.  **Inbound Endpoint:** It gets an IP address (e.g., `10.1.0.4`) that acts as a DNS server.
3.  **Forwarding (On-Prem):** You configure your On-Premises DNS servers (often **Windows Domain Controllers**) with **Conditional Forwarders**.
    *   **Rule:** "If anyone asks for `azurecr.io`, send them to `10.1.0.4`."
    *   **Destination:** The Inbound IP of the Azure Private DNS Resolver (`10.1.0.4`).

> **⚠️ Critical:** Forward to **public** zones (`azurecr.io`, `database.azure.com`), **NOT** `privatelink.*` zones. Public DNS returns a CNAME to the privatelink subdomain, which the Resolver then resolves to the private IP.

### The Flow
1.  On-prem laptop requests `myacr.azurecr.io`.
2.  Domain Controller forwards to `10.1.0.4` (Azure Resolver).
3.  Resolver gets CNAME `myacr.privatelink.azurecr.io` from public DNS.
4.  Resolver checks Private DNS Zone, finds `10.0.1.5`.
5.  Laptop connects to `10.0.1.5` via VPN. ✅

---

## 4. Architecture Implementation (vWAN & Hub-Spoke)

![Detailed Hybrid DNS Traffic Flow](./images/azure-dns-private-resolver-on-premises-query-traffic.svg)
*Figure 1: Detailed On-Premises to Azure DNS Query Traffic Flow (Source: Microsoft)*

In a typical Enterprise environment using **Azure Virtual WAN (vWAN)** or Hub & Spoke:

### The "Hub" (Shared Services)
*   **Location:** This is where the **Private DNS Resolver** lives.
*   **Connectivity:** All Spoke VNets (where workloads live) peer to this Hub.
*   **Linking:** All Private DNS Zones (`privatelink...`) are linked to this Hub VNet.

### The "Spokes" (Workloads)
*   **Resources:** AKS, Web Apps, Databases.
*   **Configuration:** The custom DNS setting on the Spoke VNet is set to point to the **Private DNS Resolver's IP**.
*   **Result:** All workloads in all spokes can resolve each other's private endpoints via the central Hub.

---

## 5. Real World Example: Accessing Private PostgreSQL

Let's trace a connection attempt from a developer's On-Prem VDI to a detailed **Azure PostgreSQL Flexible Server**.

**Scenario:** User tries to connect to `my-postgres-db.postgres.database.azure.com`.

### Step 1: DNS Resolution (The Lookup)
1.  **End User:** Enters hostname in `pgAdmin` on their VDI.
2.  **On-Prem DNS:** Receives query. Sees Conditional Forwarder for `database.azure.com`.
3.  **Firewall Rule 1 (DNS):** Traffic allowed from **On-Prem DNS** -> **Azure Resolver Inbound IP** on **Port 53**.
4.  **Azure Resolver:** Queries the linked Private DNS Zone (`privatelink.postgres.database.azure.com`) and returns the Private IP (e.g., `10.2.0.4`).

### Step 2: Network Connectivity (The Data)
1.  **VDI Client:** Now knows the destination is `10.2.0.4`.
2.  **Firewall Rule 2 (App):** Traffic allowed from **On-Prem Subnet** -> **PostgreSQL Private Endpoint Subnet** on **Port 5432**.
3.  **Connection Established.**

### Step 3: The Reverse (Outbound Endpoint)
*   **What if:** The PostgreSQL server needs to authenticate a user against an **On-Prem Domain controller** (LDAP)?
*   **Outbound Endpoint:** The Azure Private DNS Resolver uses its **Outbound Endpoint** to forward DNS queries from Azure *back* to your On-Prem DNS servers. This allows Azure resources to resolve names like `dc01.corp.local`.

---

## Summary Cheat Sheet

| Component | Role | Location |
|-----------|------|----------|
| **Private Endpoint** | Provides the Private IP (`10.x.x.x`) | Spoke VNet (Subnet) |
| **Private DNS Zone** | Maps Name -> Private IP | Global (Linked to VNets) |
| **Private DNS Resolver** | Answers DNS queries from On-Prem | Hub VNet (Dedicated Subnet) |
| **VNet Link** | Allows a VNet to read the Zone | Link Hub VNet to Zone |
| **Conditional Forwarder**| Directs On-Prem traffic to Azure | On-Prem DNS Server |

---

## Reference

![Resolver Architecture](./images/resolver-architecture.png)
*Figure 2: Simplified Resolver Architecture*

*   **Official List of Private DNS Zones:** [Azure Private Endpoint DNS configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
    *   *Bookmark this! It lists the specific `privatelink` zone names for every Azure service (Blob, SQL, ACR, etc.).*
*   [Azure DNS Private Resolver Overview](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)
*   [Azure DNS Private Resolver Architecture](https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/azure-dns-private-resolver)
*   [Private Link and DNS in Virtual WAN](https://learn.microsoft.com/en-us/azure/architecture/networking/guide/private-link-virtual-wan-dns-guide)
