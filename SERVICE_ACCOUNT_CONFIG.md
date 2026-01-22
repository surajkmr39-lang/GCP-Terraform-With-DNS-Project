# 🔐 Service Account Configuration

## Your GCP Project Details

### **Project Information**
- **Project ID**: `strange-passage-483616-i1`
- **Organization ID**: `315400019148`
- **Domain**: `learningmyway.space`

### **Service Account Details**
- **Email**: `galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com`
- **Project**: `praxis-gear-483220-k4`

---

## 🚨 Important Security Notes

### **Service Account Usage**
The service account `galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com` appears to be from a different project (`praxis-gear-483220-k4`) than your target project (`strange-passage-483616-i1`).

### **Recommended Setup**

#### **Option 1: Use Application Default Credentials (Recommended)**
```bash
# Authenticate with your user account
gcloud auth application-default login

# Set the correct project
gcloud config set project strange-passage-483616-i1

# Verify authentication
gcloud auth list
gcloud config list
```

#### **Option 2: Create Project-Specific Service Account**
```bash
# Set your project
gcloud config set project strange-passage-483616-i1

# Create a new service account for this project
gcloud iam service-accounts create terraform-dns-lab \
    --display-name="Terraform DNS Lab Service Account" \
    --description="Service account for Terraform DNS Lab deployment"

# Grant necessary permissions
gcloud projects add-iam-policy-binding strange-passage-483616-i1 \
    --member="serviceAccount:terraform-dns-lab@strange-passage-483616-i1.iam.gserviceaccount.com" \
    --role="roles/editor"

# Create and download key
gcloud iam service-accounts keys create ~/terraform-dns-lab-key.json \
    --iam-account=terraform-dns-lab@strange-passage-483616-i1.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=~/terraform-dns-lab-key.json
```

---

## 🔧 Authentication Setup

### **Method 1: User Authentication (Easiest)**
```bash
# Login with your Google account
gcloud auth login

# Set application default credentials
gcloud auth application-default login

# Set your project
gcloud config set project strange-passage-483616-i1

# Verify setup
gcloud config list
gcloud auth list
```

### **Method 2: Service Account Key File**
```bash
# If you have a service account key file
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"

# Or set in PowerShell (Windows)
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\your\service-account-key.json"
```

### **Method 3: Terraform Provider Configuration**
```hcl
# In your main.tf, you can specify credentials explicitly
provider "google" {
  project     = "strange-passage-483616-i1"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = file("path/to/service-account-key.json")  # Optional
}
```

---

## ✅ Verification Steps

### **Check Project Access**
```bash
# Verify you can access the project
gcloud projects describe strange-passage-483616-i1

# Check available regions
gcloud compute regions list

# Check quotas
gcloud compute project-info describe --project=strange-passage-483616-i1
```

### **Test API Access**
```bash
# Test Compute Engine API
gcloud compute zones list --project=strange-passage-483616-i1

# Test DNS API
gcloud dns managed-zones list --project=strange-passage-483616-i1

# Test IAM API
gcloud iam service-accounts list --project=strange-passage-483616-i1
```

---

## 🎯 Recommended Approach

For this lab, I recommend using **Method 1 (User Authentication)** because:

1. **Simplest setup** - no key file management
2. **Secure** - uses your Google account permissions
3. **Easy to manage** - works with gcloud CLI seamlessly
4. **No key rotation** - Google handles authentication

### **Quick Setup Commands**
```bash
# 1. Authenticate
gcloud auth login
gcloud auth application-default login

# 2. Set project
gcloud config set project strange-passage-483616-i1

# 3. Enable APIs
gcloud services enable compute.googleapis.com dns.googleapis.com iam.googleapis.com

# 4. Verify
gcloud config list
terraform init
terraform plan
```

---

## 🔒 Security Best Practices

1. **Never commit service account keys** to version control
2. **Use least privilege** - only grant necessary permissions
3. **Rotate keys regularly** if using service account keys
4. **Monitor usage** - check Cloud Audit Logs
5. **Use different service accounts** for different environments

---

## 📝 Notes

- Your domain `learningmyway.space` is configured in the DNS settings
- The project `strange-passage-483616-i1` will be used for all resources
- Organization ID `315400019148` provides the billing and organizational context
- Service account from different project may need cross-project permissions if used

Choose the authentication method that works best for your setup and security requirements!