# 🔐 Workload Identity Federation Implementation Guide

## 🎯 Your Specific Use Case: Single SA with WIF

### **Current Lab Service Accounts (3 SAs)**
```yaml
1. compute-service-account@strange-passage-483616-i1.iam.gserviceaccount.com
2. dns-service-account@strange-passage-483616-i1.iam.gserviceaccount.com  
3. lb-service-account@strange-passage-483616-i1.iam.gserviceaccount.com
```

### **Your Proposed Approach: Single SA with WIF**
```yaml
Idea: Use one service account for entire lab deployment via WIF
Repository: https://github.com/surajkmr39-lang/GCP-Terraform
Goal: Deploy entire infrastructure without service account keys
```

---

## 🏗️ WIF Implementation for Your Lab

### **Step 1: Create Single Terraform Service Account**

```bash
# Set your project
gcloud config set project strange-passage-483616-i1

# Create single service account for Terraform
gcloud iam service-accounts create terraform-dns-lab \
    --display-name="Terraform DNS Lab Service Account" \
    --description="Single SA for entire DNS lab deployment via WIF"

# Grant comprehensive permissions (for lab purposes)
gcloud projects add-iam-policy-binding strange-passage-483616-i1 \
    --member="serviceAccount:terraform-dns-lab@strange-passage-483616-i1.iam.gserviceaccount.com" \
    --role="roles/editor"

# Additional specific permissions
gcloud projects add-iam-policy-binding strange-passage-483616-i1 \
    --member="serviceAccount:terraform-dns-lab@strange-passage-483616-i1.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding strange-passage-483616-i1 \
    --member="serviceAccount:terraform-dns-lab@strange-passage-483616-i1.iam.gserviceaccount.com" \
    --role="roles/resourcemanager.projectIamAdmin"
```

### **Step 2: Set Up Workload Identity Pool**

```bash
# Get your project number
PROJECT_NUMBER=$(gcloud projects describe strange-passage-483616-i1 --format="value(projectNumber)")
echo "Project Number: $PROJECT_NUMBER"

# Create Workload Identity Pool
gcloud iam workload-identity-pools create github-terraform-pool \
    --project="strange-passage-483616-i1" \
    --location="global" \
    --description="GitHub Actions pool for Terraform DNS Lab"

# Create OIDC Provider for GitHub
gcloud iam workload-identity-pools providers create-oidc github-terraform-provider \
    --project="strange-passage-483616-i1" \
    --location="global" \
    --workload-identity-pool="github-terraform-pool" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor" \
    --attribute-condition="assertion.repository=='surajkmr39-lang/GCP-Terraform'"
```

### **Step 3: Bind Service Account to WIF**

```bash
# Allow GitHub Actions to impersonate the service account
gcloud iam service-accounts add-iam-policy-binding \
    terraform-dns-lab@strange-passage-483616-i1.iam.gserviceaccount.com \
    --project="strange-passage-483616-i1" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-terraform-pool/attribute.repository/surajkmr39-lang/GCP-Terraform"

# Get the Workload Identity Provider name
WIF_PROVIDER="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-terraform-pool/providers/github-terraform-provider"
echo "WIF Provider: $WIF_PROVIDER"
```

---

## 🚀 GitHub Actions Workflow

### **Create .github/workflows/terraform.yml**

```yaml
name: 'Terraform DNS Lab Deployment'

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

permissions:
  contents: read
  id-token: write

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: production

    defaults:
      run:
        shell: bash

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Authenticate to Google Cloud
      uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: 'projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-terraform-pool/providers/github-terraform-provider'
        service_account: 'terraform-dns-lab@strange-passage-483616-i1.iam.gserviceaccount.com'

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v2

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.6.0"

    - name: Terraform Format
      id: fmt
      run: terraform fmt -check

    - name: Terraform Init
      id: init
      run: terraform init

    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color

    - name: Terraform Plan
      id: plan
      if: github.event_name == 'pull_request'
      run: terraform plan -no-color -input=false
      continue-on-error: true

    - name: Terraform Plan Status
      if: steps.plan.outcome == 'failure'
      run: exit 1

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve -input=false
```

---

## 🔧 Modified Terraform Configuration

### **Update main.tf Provider Configuration**

```hcl
# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  # No credentials specified - will use WIF
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  # No credentials specified - will use WIF
}
```

### **Simplified IAM Module (modules/iam/main.tf)**

```hcl
# Since we're using single SA approach, we can simplify this
# Keep the custom roles but remove separate service accounts

# Custom IAM Role for DNS operations (keep this)
resource "google_project_iam_custom_role" "dns_manager" {
  role_id     = "dnsManager"
  title       = "DNS Manager"
  description = "Custom role for DNS management operations"
  project     = var.project_id
  
  permissions = [
    "dns.managedZones.create",
    "dns.managedZones.delete",
    "dns.managedZones.get",
    "dns.managedZones.list",
    "dns.managedZones.update",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
    "dns.policies.create",
    "dns.policies.delete",
    "dns.policies.get",
    "dns.policies.list",
    "dns.policies.update"
  ]
}

# Use default compute service account for instances
# This simplifies the setup while maintaining functionality
```

### **Update Instance Configuration**

```hcl
# In modules/instances/main.tf
service_account {
  # Use default compute service account or specify the WIF SA
  email  = "terraform-dns-lab@strange-passage-483616-i1.iam.gserviceaccount.com"
  scopes = ["cloud-platform"]
}
```

---

## 📊 Comparison: Current vs WIF Approach

### **Current Lab Approach (3 SAs)**
```yaml
Pros:
  ✅ Demonstrates service account separation
  ✅ Good for learning IAM concepts
  ✅ Shows enterprise patterns
  
Cons:
  ❌ More complex for simple lab
  ❌ Requires managing multiple SAs
  ❌ Still uses service account keys (if not using ADC)
```

### **Single SA with WIF Approach**
```yaml
Pros:
  ✅ No service account keys
  ✅ Automatic credential rotation
  ✅ Simpler deployment pipeline
  ✅ Better security (no long-lived credentials)
  ✅ GitHub Actions integration
  ✅ Easier to manage for lab purposes
  
Cons:
  ❌ Single point of failure
  ❌ Broader permissions than needed
  ❌ Less educational for IAM best practices
```

---

## 🏢 Enterprise Reality Check

### **What Companies Actually Do**

#### **Small to Medium Companies:**
```yaml
Approach: Single SA with WIF for CI/CD
Reasoning: 
  - Simpler to manage
  - Faster development cycles
  - Lower operational overhead
  - Good security with WIF
```

#### **Large Enterprises:**
```yaml
Approach: Multiple SAs with WIF
Reasoning:
  - Compliance requirements
  - Risk management
  - Audit requirements
  - Separation of duties
```

#### **Startups/Labs:**
```yaml
Approach: Your proposed single SA with WIF
Reasoning:
  - Speed of development
  - Minimal operational overhead
  - Focus on functionality over governance
```

---

## 🎯 Recommendation for Your Lab

### **Go with Single SA + WIF Approach**

**Why this makes sense for your lab:**
1. **Learning Focus**: You're learning Terraform and GCP, not IAM governance
2. **Simplicity**: Easier to set up and maintain
3. **Modern Practice**: WIF is the current best practice
4. **Security**: Better than service account keys
5. **Real-world Relevant**: Many companies use this approach

### **Implementation Steps:**
```bash
1. Create single terraform-dns-lab service account
2. Set up WIF pool and provider
3. Configure GitHub Actions workflow
4. Simplify Terraform IAM module
5. Deploy and test
```

### **Future Evolution:**
```yaml
Lab Phase: Single SA with WIF ✅
Learning Phase: Understand why multiple SAs exist
Enterprise Phase: Implement multiple SAs when needed
```

---

## 🔒 Security Considerations

### **Single SA Security Measures:**
```yaml
1. Principle of Least Privilege:
   - Grant only necessary permissions
   - Use custom roles where possible
   - Regular permission audits

2. WIF Security:
   - Restrict to specific repository
   - Use attribute conditions
   - Monitor usage logs

3. Monitoring:
   - Enable audit logs
   - Set up alerts for unusual activity
   - Regular access reviews
```

### **Risk Mitigation:**
```yaml
1. Repository Security:
   - Branch protection rules
   - Required reviews for main branch
   - Secrets scanning enabled

2. Deployment Controls:
   - Manual approval for production
   - Terraform plan review required
   - Rollback procedures documented

3. Monitoring:
   - Cloud Audit Logs enabled
   - Billing alerts configured
   - Resource quotas set
```

---

## 🎉 Conclusion

**Your idea of using a single service account with WIF is actually a great approach for this lab!**

It's:
- ✅ **Modern and secure** (no keys)
- ✅ **Practical for learning**
- ✅ **Used by many companies**
- ✅ **Easier to implement and maintain**

The multiple service account approach in the current code is more for **educational purposes** to show enterprise patterns. For your actual deployment, the single SA + WIF approach is perfectly valid and recommended.

**Next Steps:**
1. Implement the WIF setup above
2. Modify the Terraform code to use single SA
3. Set up GitHub Actions workflow
4. Deploy and enjoy the keyless authentication! 🚀