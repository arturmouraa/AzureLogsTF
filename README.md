# AzureLogsTF

This repository provisions a small Azure lab using Terraform to demonstrate forwarding Azure AD (Entra ID) logs to an Event Hub and storing data in a Storage Account. It's intended for testing and troubleshooting Azure Logs integration (diagnostic settings -> Event Hubs).

Contents
- `main.tf`, `eventhub.tf`, `resource_group.tf`, `storage.tf`, `diagnostic_settings.tf`, `providers.tf`, `vars.tf` — Terraform configuration files
- `PORTAL_GUIDE.md` — step-by-step guide to recreate the resources in the Azure Portal

What this creates
- Resource Group
- Event Hubs Namespace + Event Hub + Consumer Group
- Event Hubs authorization rule (shared access policy)
- Storage Account
- Azure AD (Entra ID) diagnostic setting that streams selected log categories to the Event Hub

Quick start
1. Install Terraform (>= 1.0) and authenticate with Azure CLI: `az login`
2. Initialize Terraform

```bash
terraform init
```

3. Review and set variables. The repository declares variables in `vars.tf`. You can provide values via `terraform.tfvars` or environment variables. Example `terraform.tfvars`:

```hcl
location = "eastus"
lab = "demo"
```

4. Plan and apply

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

Outputs
The Terraform configuration exposes a few outputs (see `main.tf`):
- `event_hub_name` — the Event Hub name
- `ConsumerGroup` — consumer group name
- `connectionString` — primary connection string for the authorization rule (nonsensitive in this repo's outputs)
- `storageaccount` — Storage Account name
- `storage_account_key` — primary storage account key (nonsensitive in outputs)

Notes and caveats
- The provider configuration in `providers.tf` may contain a hard-coded `subscription_id`. It's recommended to remove hard-coded credentials and let `az login` or environment variables provide authentication.
- Creating a diagnostic setting for Entra ID (Azure AD) may require tenant-level admin privileges (Global Administrator) and sometimes interactive authentication. If automation fails, create the diagnostic setting in the Azure Portal as described in `PORTAL_GUIDE.md`.
- Some API calls for AAD diagnostic settings are tenant-scoped and may not appear with service principals or limited scopes.

Portal recreation guide
Refer to `PORTAL_GUIDE.md` for a step-by-step guide to recreate the resources in the Azure Portal and for CLI verification snippets.

Next steps (optional)
- Add a small consumer application (Python/Node) to read messages from the Event Hub and validate logs arrival.
- Add CI that runs `terraform fmt`, `terraform validate`, and optionally `tflint` or `checkov` for static checks.