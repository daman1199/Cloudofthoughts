# Terraform Examples - Part 1

This folder contains working Terraform examples from Part 1 of the Azure + Terraform Series.

## Examples

### 01-simple-single-file
**Purpose:** Beginner-friendly single-file example  
**What it creates:** A single resource group  
**Files:** `main.tf` only

**Use this when:**
- Learning Terraform basics
- Quick testing
- Simple deployments

**To deploy:**
```bash
cd 01-simple-single-file
az login
terraform init
terraform plan
terraform apply
```

---

### 02-multi-file-structure
**Purpose:** Professional multi-file organization  
**What it creates:** Resource group + Virtual Network  
**Files:** `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`, `.gitignore`

**Use this when:**
- Building production code
- Working in teams
- Need reusable configurations

**To deploy:**
```bash
cd 02-multi-file-structure
az login
terraform init
terraform plan
terraform apply
```

**To customize:**
```bash
# Override variables
terraform apply -var="environment=prod" -var="location=West US"

# Or create terraform.tfvars
echo 'environment = "prod"' > terraform.tfvars
terraform apply
```

---

### 03-exercise-solution
**Purpose:** Complete hands-on exercise solution  
**What it creates:**
- Resource group
- Virtual network (10.0.0.0/16)
- Web subnet (10.0.1.0/24)
- Data subnet (10.0.2.0/24)
- Network security group

**Files:** `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`

**To deploy:**
```bash
cd 03-exercise-solution
az login
terraform init
terraform plan
terraform apply
```

---

## General Tips

### Before Running Any Example:

1. **Authenticate to Azure:**
   ```bash
   az login
   az account set --subscription "YOUR-SUBSCRIPTION-NAME"
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Preview changes:**
   ```bash
   terraform plan
   ```

4. **Apply changes:**
   ```bash
   terraform apply
   ```

5. **Clean up:**
   ```bash
   terraform destroy
   ```

### Best Practices:

- ✅ Always run `terraform plan` before `apply`
- ✅ Review the plan output carefully
- ✅ Use `terraform destroy` to clean up test resources
- ✅ Never commit `.tfstate` files to Git
- ✅ Use variables for reusable values

---

[← Back to Part 1 Guide](../README.md)
