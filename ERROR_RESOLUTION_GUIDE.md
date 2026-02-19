# Error Resolution Guide

## Critical Error Identified

**Error Type:** Missing Variable Definitions  
**Impact:** CI/CD pipeline will fail on `terraform plan` step  
**Severity:** HIGH

---

## Problem Analysis

### Root Cause
The `variables.tf` file is **empty**, but the codebase references three required variables:
- `var.github_token` (in `provider.tf`)
- `var.github_owner` (in `provider.tf`)
- `var.aws_region` (in `provider.tf`)
- `var.repositories` (in `repos.tf`)

### Why This Fails
1. **Local execution**: Works because `terraform.tfvars` provides `repositories` value, but `github_token`, `github_owner`, and `aws_region` are undefined
2. **CI/CD execution**: The GitHub Actions workflow (`.github/workflows/ci.yml`) runs `terraform plan` without any variable values or authentication, causing immediate failure

---

## Resolution Steps

### Step 1: Define Missing Variables in `variables.tf`

Add the following variable declarations to `variables.tf`:

```hcl
variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub organization or username"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "repositories" {
  description = "Map of GitHub repositories to create"
  type = map(object({
    description = string
    visibility  = string
    topics      = list(string)
  }))
}
```

### Step 2: Configure GitHub Actions Secrets

Add these secrets to your GitHub repository:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following repository secrets:
   - `GITHUB_TOKEN`: Your GitHub Personal Access Token with `repo` and `admin:org` scopes
   - `AWS_ACCESS_KEY_ID`: AWS access key (if using AWS provider)
   - `AWS_SECRET_ACCESS_KEY`: AWS secret key (if using AWS provider)

### Step 3: Update CI Workflow

Modify `.github/workflows/ci.yml` to pass required variables:

```yaml
name: CI

on:
  push:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    env:
      TF_VAR_github_token: ${{ secrets.GH_PAT }}
      TF_VAR_github_owner: ${{ github.repository_owner }}
      TF_VAR_aws_region: us-east-1
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: hashicorp/setup-terraform@v3
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Validate
        run: terraform validate
      
      - name: Terraform Plan
        run: terraform plan
```

**Note:** Use `GH_PAT` (Personal Access Token) instead of the default `GITHUB_TOKEN` because the default token has limited permissions for repository management.

### Step 4: Alternative - Use Terraform Cloud/Backend

For better secret management, configure a remote backend:

```hcl
# Add to provider.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "github-infra/terraform.tfstate"
    region = "us-east-1"
  }
  
  required_providers {
    # ... existing providers
  }
}
```

Then set variables in Terraform Cloud or use AWS Systems Manager Parameter Store.

---

## Additional Issues Found

### 1. Unused AWS Provider
- **Issue**: AWS provider is configured but not used anywhere
- **Resolution**: Either remove it or add AWS resources

### 2. Unused Helm Provider
- **Issue**: Helm provider is declared but not configured or used
- **Resolution**: Remove if not needed, or configure properly

### 3. Empty Output Files
- **Issue**: `outputs.tf` files are empty
- **Resolution**: Add useful outputs like repository URLs

### 4. Incomplete .gitignore
- **Issue**: Missing common Terraform files
- **Resolution**: Add `.terraform/`, `*.tfstate.backup`, `.terraform.lock.hcl`

---

## Testing the Fix

After implementing the changes:

1. **Local test:**
   ```bash
   export TF_VAR_github_token="your_token"
   export TF_VAR_github_owner="your_org"
   terraform init
   terraform plan
   ```

2. **CI test:**
   - Push changes to a feature branch
   - Verify the workflow runs successfully
   - Check for any authentication errors

---

## Summary

**Minimum Required Changes:**
1. ✅ Add variable definitions to `variables.tf`
2. ✅ Configure GitHub Actions secrets
3. ✅ Update CI workflow with environment variables

**Optional Improvements:**
- Remove unused providers (AWS, Helm)
- Add meaningful outputs
- Improve .gitignore
- Add terraform.tfvars.example for documentation
