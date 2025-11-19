"""
# Guide: Recreate the resources from `main.tf` using the Azure Portal

This guide reproduces, step by step, what `main.tf` creates: a Resource Group, an Event Hubs namespace, an Event Hub, a Shared Access Policy (`send`) and the Entra ID (Azure AD) Diagnostic Setting that forwards logs to the Event Hub.

Use the names/values defined in `main.tf` as defaults (suggested values are shown in parentheses).

## Prerequisites
- An account with sufficient permissions in the subscription (e.g. Contributor to create resources) and privileges in the tenant (Global Administrator or equivalent) to configure Azure AD Diagnostic Settings.
- Access to the Azure Portal: https://portal.azure.com

## 1. Sign in to the Portal
1. Open https://portal.azure.com and sign in with the correct account.
2. Confirm you are in the correct subscription/tenant (top-right corner).

> Note: Creating a Diagnostic Setting for Entra ID usually requires tenant-level admin privileges (Global Admin).

## 2. Create the Resource Group
- Portal: Menu ➜ Resource groups ➜ + Create
  - Subscription: select your subscription
  - Resource group name: `<RESOURCE_GROUP>`
  - Region: `<LOCATION>`
  - Create

## 3. Create the Event Hubs Namespace
- Portal: Search for "Event Hubs" ➜ Namespaces ➜ + Create
  - Subscription: same subscription
  - Resource group: `<RESOURCE_GROUP>`
  - Namespace name: `<EVENTHUB_NAMESPACE>`
  - Location: `<LOCATION>`
  - Pricing tier / SKU: `Standard`
  - Capacity / Throughput units: `1`
  - Create (wait for provisioning)

## 4. Create the Storage Account
- Portal: Menu ➜ Storage accounts ➜ + Create
  - Subscription: select your subscription
  - Resource group: `<RESOURCE_GROUP>`
  - Storage account name: `<STORAGE_ACCOUNT_NAME>` (must be 3-24 characters, lowercase letters and numbers)
  - Region: `<LOCATION>`
  - Performance: `Standard`
  - Replication: `Locally-redundant storage (LRS)`
  - Access tier (default): `Hot`
  - Advanced / Data protection: **Enable hierarchical namespace (Data Lake Storage Gen2)**: `Off` 
  - Minimum TLS version: `TLS1_2`
  - Review + Create

Important notes about the storage account
- Storage account names must be globally unique across Azure and only contain lowercase letters and numbers. The Terraform configuration uses a lower-cased name pattern (e.g. `stgacct${var.lab}`).
- To retrieve access keys or a connection string via the Portal: open the Storage Account ➜ Access keys (or Settings ➜ Access keys) and copy the `key1` value or the connection string.

## 5. Create the Event Hub inside the Namespace
 - Portal: Event Hubs ➜ select namespace `<EVENTHUB_NAMESPACE>` ➜ Event Hubs ➜ + Event Hub
  - Name: `<EVENTHUB_NAME>`
  - Partition count: `<PARTITION_COUNT>`
  - Message retention (days): `<MESSAGE_RETENTION_DAYS>`
  - Create

  After creating the Event Hub, create a Consumer Group (used by consumers to read from the Event Hub):
  - Portal: select Event Hub `<EVENTHUB_NAME>` ➜ Consumer groups ➜ + Add
    - Name: `<CONSUMER_GROUP_NAME>`
    - Create

 ## 6. Create the Shared Access Policy (authorization rule) in the Namespace
  - In the namespace `<EVENTHUB_NAMESPACE>` ➜ Shared access policies ➜ + Add
   - Name: `<AUTHORIZATION_RULE_NAME>`
   - Permissions: check `Listen` and `Send` (uncheck `Manage`)
   - Create

Note that this policy (rule) will be used by the Entra ID diagnostic setting as the authorization rule.

## 7. Create the Diagnostic Setting on Azure AD (Entra ID)
- Portal: search for and open **Azure Active Directory**
- Inside the Azure AD blade, look for **Diagnostic settings** (may be under "Monitoring" or use the portal search)
- Click **+ Add diagnostic setting**
  - Name: `<DIAGNOSTIC_SETTING_NAME>`
  - Destination: choose **Stream to an event hub**
  - Event hub namespace: select `<EVENTHUB_NAMESPACE>`
  - Event hub: select `<EVENTHUB_NAME>`
  - Event hub authorization rule: select `<AUTHORIZATION_RULE_NAME>`
  - Under **Logs**, check the categories:
    - `SignInLogs`
    - `NonInteractiveUserSignInLogs`
  - Save / Create

Important notes about retention and authentication
- If the portal shows retention fields during creation and you receive an error (for example: HTTP 400 / "Diagnostic settings does not support retention for new diagnostic settings"), do not enable per-category retention—leave those fields disabled or empty. For Entra ID, creation often rejects retention policies applied at creation time.
- Some Entra ID actions require interactive authentication (user login) and may not be compatible with Service Principals. If automation fails due to permissions/scope, try creating the setting in the Portal with an administrator account.

## 8. Quick verification via Portal and CLI
- Confirm the Namespace and Event Hub were created successfully.

## 9. Quick mapping (Terraform -> Portal)
 - `azurerm_resource_group.main` ➜ Resource group `<RESOURCE_GROUP>`
 - `azurerm_eventhub_namespace.main` ➜ Event Hubs namespace `<EVENTHUB_NAMESPACE>` (SKU: Standard, capacity: 1)
 - `azurerm_eventhub.entraid_logs` ➜ Event Hub `<EVENTHUB_NAME>` (partitions = `<PARTITION_COUNT>`, message_retention = `<MESSAGE_RETENTION_DAYS>` day(s))
 - `azurerm_storage_account.lab` ➜ Storage account `<STORAGE_ACCOUNT_NAME>` (replication = `LRS`, access_tier = `Hot`, TLS minimum = `TLS1_2`)
 - `azurerm_eventhub_namespace_authorization_rule.send_rule` ➜ Shared access policy `<AUTHORIZATION_RULE_NAME>` (Send permission)
 - `azurerm_monitor_aad_diagnostic_setting.entraid` ➜ Azure AD Diagnostic Setting `<DIAGNOSTIC_SETTING_NAME>` (stream to Event Hub using the `<AUTHORIZATION_RULE_NAME>` rule)