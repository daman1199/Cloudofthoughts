---
layout: page
title: "ClickOps to Terraform"
permalink: /engineering-handbook/clickops-to-terraform/
tags:
  - azure
  - terraform
  - devops
  - iac
  - series
status: published
type: series
date: 2025-12-20
summary: "A 5-part series on transitioning from manual Azure portal work to automated, repeatable infrastructure with Terraform."
ShowToc: true
---
*A 5-part series on transitioning from manual Azure portal work to automated, repeatable infrastructure with Terraform.*

| Series Info | Details |
|-------------|---------|
| **Total Parts** | 5 |
| **Difficulty** | Beginner to Advanced |
| **Prerequisites** | Basic Azure knowledge, command line familiarity |
| **Estimated Time** | 8-10 hours total |

---

## Series Overview

If you've been managing Azure resources through the portal—clicking, configuring, and hoping you remember what you did last time—this series is for you.

**ClickOps to Terraform** takes you on a complete journey from manual portal work to fully automated, version-controlled infrastructure. You'll learn not just the "how," but the "why" behind each decision, building a solid foundation for enterprise-grade Infrastructure as Code practices.

By the end of this series, you'll:
- ✅ Confidently write Terraform code for Azure resources
- ✅ Understand how authentication works locally and in pipelines
- ✅ Set up Azure DevOps with service principals and remote state
- ✅ Build automated CI/CD pipelines for infrastructure deployment
- ✅ Import existing Azure resources into Terraform management
- ✅ Lead your team's transition away from ClickOps

---

> 📅 **Release Schedule:** Part 1 is available now. New parts will be released weekly—check back soon!

## Series Parts

### [Part 1: Terraform with Azure CLI](/engineering-handbook/series/terraform-essentials/01-terraform-with-azure-cli/) ✅ **Available Now**
**Foundation: Running Terraform Locally**

Start your IaC journey by running Terraform on your local machine. No pipelines, no complexity—just you, your terminal, and Azure. Learn the fundamentals of HCL syntax, authentication, and the Terraform workflow (`init`, `plan`, `apply`).

**Topics Covered:**
- Installing and configuring Terraform
- The Terraform workflow: init, plan, apply, destroy
- Understanding HCL syntax and structure
- Local authentication with Azure CLI
- Professional multi-file structure
- The state file and why it matters

**Estimated Time:** 1 hour

---

### Part 2: Setting Up Azure DevOps & Terraform 🔜 **Coming Soon**
**Automation: Moving to the Cloud**

Graduate from local development to team-ready automation. Learn how to set up Azure DevOps pipelines, configure service principals, and implement remote state storage. This is where your infrastructure becomes truly scalable and collaborative.

**Topics Covered:**
- Creating and configuring service principals
- Setting up Azure DevOps service connections
- Configuring remote state in Azure Storage
- Building your first Terraform pipeline
- Understanding pipeline authentication
- Troubleshooting common setup issues

**Estimated Time:** 2-3 hours

---

### Part 3: Getting Comfortable with Terraform 🔜 **Coming Soon**
**Mastery: Building Confidence**

Bridge the gap between "I got it working" and "I'm comfortable with this." This part focuses on gaining fluency with Terraform—understanding variables, outputs, remote state patterns, and building the confidence to adopt Terraform more broadly.

**Topics Covered:**
- Variables, locals, and outputs (when to use what)
- Remote state deep dive
- Resource dependencies and ordering
- Working with data sources
- Debugging common Terraform issues
- Hands-on practice scenarios
- Best practices checklist

**Estimated Time:** 2-3 hours

---

### Part 4: Importing Existing Resources 🔜 **Coming Soon**
**Migration: Bringing in What You've Already Built**

Already have Azure resources created manually? Learn how to bring them under Terraform management without destroying and recreating everything. Master `terraform import` and the newer `aztfexport` tool.

**Topics Covered:**
- Understanding `terraform import`
- Using `aztfexport` to generate Terraform code
- Writing Terraform code for existing infrastructure
- Handling state conflicts and drift detection
- Migration strategies and best practices
- Avoiding common pitfalls

**Estimated Time:** 1-2 hours

---

### Part 5: Adopting Terraform as an Organization 🔜 **Coming Soon**
**Scale: Moving Your Team Away from ClickOps**

You've learned Terraform—now how do you get your team on board? This final part covers strategies for organizational adoption, establishing standards, and creating a culture where Infrastructure as Code becomes the default.

**Topics Covered:**
- Making the case for Terraform to leadership
- Establishing team conventions and standards
- Module development and sharing
- Gradual adoption strategies
- Handling resistance and common objections
- Coexistence strategies during transition
- Building a Terraform-first culture

**Estimated Time:** 1-2 hours

---

## Learning Path

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Part 1: Local Development ✅ AVAILABLE                     │
│  ├─ Install Terraform                                       │
│  ├─ Learn HCL syntax                                        │
│  ├─ Deploy your first resource                              │
│  └─ Master the Terraform workflow                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Part 2: Azure DevOps Automation 🔜 COMING SOON            │
│  ├─ Create service principals                               │
│  ├─ Configure remote state                                  │
│  ├─ Build basic CI/CD pipelines                             │
│  └─ Automate deployments                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Part 3: Getting Comfortable 🔜 COMING SOON                │
│  ├─ Variables, outputs, locals                              │
│  ├─ Remote state patterns                                   │
│  ├─ Debugging and troubleshooting                           │
│  └─ Building confidence                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Part 4: Importing Existing Resources 🔜 COMING SOON       │
│  ├─ terraform import & aztfexport                           │
│  ├─ Handle state management                                 │
│  ├─ Migration strategies                                    │
│  └─ Avoid common pitfalls                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Part 5: Organizational Adoption 🔜 COMING SOON            │
│  ├─ Team standards and conventions                          │
│  ├─ Module development                                      │
│  ├─ Gradual adoption strategies                             │
│  └─ Building a Terraform-first culture                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

Before starting this series, you should have:
- An active Azure subscription with Contributor access
- Basic familiarity with Azure resources (Resource Groups, VNets, etc.)
- Command line/terminal experience
- A code editor (VS Code recommended)
- Git installed (for Azure DevOps integration)

---

## Additional Resources

- [Official Terraform Documentation](https://www.terraform.io/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/)
- [aztfexport Documentation](https://github.com/Azure/aztfexport)

---

[← Back to Engineering Handbook](/engineering-handbook/)
