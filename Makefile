# GCP Terraform DNS Lab Makefile

.PHONY: help init plan apply destroy clean validate fmt lint docs

# Default environment
ENV ?= dev

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)GCP Terraform DNS Lab$(NC)"
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform
	@echo "$(YELLOW)Initializing Terraform...$(NC)"
	terraform init
	@echo "$(GREEN)Terraform initialized successfully!$(NC)"

validate: ## Validate Terraform configuration
	@echo "$(YELLOW)Validating Terraform configuration...$(NC)"
	terraform validate
	@echo "$(GREEN)Configuration is valid!$(NC)"

fmt: ## Format Terraform files
	@echo "$(YELLOW)Formatting Terraform files...$(NC)"
	terraform fmt -recursive
	@echo "$(GREEN)Files formatted successfully!$(NC)"

plan: ## Create Terraform execution plan
	@echo "$(YELLOW)Creating Terraform plan for $(ENV) environment...$(NC)"
	terraform plan -var-file="environments/$(ENV)/terraform.tfvars" -out=tfplan-$(ENV)
	@echo "$(GREEN)Plan created successfully!$(NC)"

apply: ## Apply Terraform configuration
	@echo "$(YELLOW)Applying Terraform configuration for $(ENV) environment...$(NC)"
	@echo "$(RED)WARNING: This will create/modify GCP resources!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform apply -var-file="environments/$(ENV)/terraform.tfvars" -auto-approve; \
		echo "$(GREEN)Infrastructure deployed successfully!$(NC)"; \
	else \
		echo "$(YELLOW)Deployment cancelled.$(NC)"; \
	fi

destroy: ## Destroy Terraform-managed infrastructure
	@echo "$(RED)WARNING: This will destroy all resources in $(ENV) environment!$(NC)"
	@read -p "Are you sure? Type 'yes' to confirm: " -r; \
	if [[ $$REPLY == "yes" ]]; then \
		terraform destroy -var-file="environments/$(ENV)/terraform.tfvars" -auto-approve; \
		echo "$(GREEN)Infrastructure destroyed successfully!$(NC)"; \
	else \
		echo "$(YELLOW)Destruction cancelled.$(NC)"; \
	fi

clean: ## Clean up temporary files
	@echo "$(YELLOW)Cleaning up temporary files...$(NC)"
	rm -f tfplan-*
	rm -f terraform.tfplan
	rm -f crash.log
	@echo "$(GREEN)Cleanup completed!$(NC)"

output: ## Show Terraform outputs
	@echo "$(YELLOW)Terraform outputs for $(ENV) environment:$(NC)"
	terraform output

state-list: ## List all resources in Terraform state
	@echo "$(YELLOW)Resources in Terraform state:$(NC)"
	terraform state list

docs: ## Generate documentation
	@echo "$(YELLOW)Generating documentation...$(NC)"
	@echo "# Terraform Resources" > RESOURCES.md
	@echo "" >> RESOURCES.md
	@terraform providers schema -json | jq -r '.provider_schemas."registry.terraform.io/hashicorp/google".resource_schemas | keys[]' | sort | while read resource; do \
		echo "- $$resource" >> RESOURCES.md; \
	done
	@echo "$(GREEN)Documentation generated in RESOURCES.md$(NC)"

lint: ## Run terraform and security linting
	@echo "$(YELLOW)Running Terraform linting...$(NC)"
	@if command -v tflint >/dev/null 2>&1; then \
		tflint; \
	else \
		echo "$(YELLOW)tflint not installed, skipping...$(NC)"; \
	fi
	@if command -v checkov >/dev/null 2>&1; then \
		echo "$(YELLOW)Running security checks with Checkov...$(NC)"; \
		checkov -d . --framework terraform; \
	else \
		echo "$(YELLOW)checkov not installed, skipping security checks...$(NC)"; \
	fi

cost-estimate: ## Estimate infrastructure costs (requires infracost)
	@if command -v infracost >/dev/null 2>&1; then \
		echo "$(YELLOW)Estimating infrastructure costs...$(NC)"; \
		infracost breakdown --path . --terraform-var-file="environments/$(ENV)/terraform.tfvars"; \
	else \
		echo "$(YELLOW)infracost not installed. Install from https://www.infracost.io/docs/$(NC)"; \
	fi

# Environment-specific targets
dev: ## Deploy to development environment
	$(MAKE) ENV=dev apply

prod: ## Deploy to production environment
	$(MAKE) ENV=prod apply

dev-plan: ## Plan for development environment
	$(MAKE) ENV=dev plan

prod-plan: ## Plan for production environment
	$(MAKE) ENV=prod plan

dev-destroy: ## Destroy development environment
	$(MAKE) ENV=dev destroy

prod-destroy: ## Destroy production environment
	$(MAKE) ENV=prod destroy

# Quick setup for new users
setup: ## Initial setup for new users
	@echo "$(BLUE)Setting up GCP Terraform DNS Lab...$(NC)"
	@echo "$(YELLOW)1. Copying example configuration...$(NC)"
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "$(GREEN)Created terraform.tfvars from example$(NC)"; \
		echo "$(YELLOW)Please edit terraform.tfvars with your project details$(NC)"; \
	else \
		echo "$(YELLOW)terraform.tfvars already exists$(NC)"; \
	fi
	@echo "$(YELLOW)2. Initializing Terraform...$(NC)"
	$(MAKE) init
	@echo "$(YELLOW)3. Validating configuration...$(NC)"
	$(MAKE) validate
	@echo "$(GREEN)Setup completed! Next steps:$(NC)"
	@echo "  1. Edit terraform.tfvars with your GCP project details"
	@echo "  2. Run 'make plan' to see what will be created"
	@echo "  3. Run 'make apply' to deploy the infrastructure"