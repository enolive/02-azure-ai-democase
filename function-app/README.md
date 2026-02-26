# Azure Function App - Document Intelligence Processor

This Azure Function automatically processes insurance claim PDFs when they are uploaded to blob storage.

## Architecture

```
PDF Upload → Blob Storage (insurance-claims container)
             ↓ (Blob Trigger)
        Azure Function
             ↓ (API Call)
    Document Intelligence
             ↓ (Extract Data)
        Fraud Detection Logic
             ↓ (Save Results)
Blob Storage (processed-data container)
```

## Features

- **Automatic Processing**: Triggers when PDFs are uploaded to the `insurance-claims` container
- **Document Analysis**: Extracts text, key-value pairs, and tables using Azure Document Intelligence
- **Fraud Detection**: Basic logic to detect date mismatches and suspicious language
- **Structured Output**: Saves results as JSON in the `processed-data` container

## Infrastructure

The infrastructure is managed by Terraform in `../terraform`:

- **Storage Account**: `dmst{project_name}` with two containers:
  - `insurance-claims` - Input PDFs (triggers function)
  - `processed-data` - JSON results
- **Function App**: `func-{project_name}` on Consumption plan (serverless)
- **Application Insights**: Monitoring and logging
- **Document Intelligence**: OCR and form extraction
- **RBAC**: Managed identity with appropriate permissions

## Deployment

### 1. Deploy Infrastructure

```bash
cd ../terraform
terraform plan
terraform apply
```

### 2. Deploy Function Code

```bash
cd ../function-app

# Install Azure Functions Core Tools (if not installed)
# brew install azure-functions-core-tools@4  # macOS
# npm install -g azure-functions-core-tools@4  # npm

# Login to Azure
az login

# Deploy function code
func azure functionapp publish func-<project-name>
```

### 3. Test the Function

```bash
# Upload a test PDF (automatically triggers processing)
az storage blob upload \
  --account-name dmstfrauddetect \
  --container-name insurance-claims \
  --name test-claim.pdf \
  --file ../sample-data/claims/legitimate-claim.pdf \
  --auth-mode login

# Wait ~10-30 seconds for automatic processing

# Download the processed results
az storage blob download \
  --account-name dmstfrauddetect \
  --container-name processed-data \
  --name test-claim_analyzed.json \
  --file output.json \
  --auth-mode login

# View extracted data and fraud indicators
cat output.json | jq .
```

## Function Configuration

Environment variables (automatically configured by Terraform):

- `DOCUMENT_INTELLIGENCE_ENDPOINT`: Document Intelligence API endpoint
- `DOCUMENT_INTELLIGENCE_KEY`: Document Intelligence API key
- `DataStorageConnection`: Connection string for blob storage
- `INPUT_CONTAINER_NAME`: Input container name (`insurance-claims`)
- `OUTPUT_CONTAINER_NAME`: Output container name (`processed-data`)

## Output Format

The function saves analyzed documents as JSON:

```json
{
  "source_file": "legitimate-claim.pdf",
  "pages": 1,
  "content": "Full extracted text...",
  "key_value_pairs": {
    "Claim Number": "CLM-2026-0001",
    "Incident Date": "02/05/2026",
    "Invoice Date": "02/08/2026"
  },
  "tables": [
    {
      "table_id": 0,
      "row_count": 5,
      "column_count": 3,
      "cells": [...]
    }
  ],
  "fraud_indicators": [
    "Invoice date before incident date"
  ]
}
```

## Monitoring

View function logs in Application Insights:

```bash
# Stream logs in real-time
func azure functionapp logstream func-<project-name>
```

Or use the Azure Portal:
- Navigate to Application Insights
- Go to "Transaction search" or "Live Metrics"
- Filter by function name: `process_insurance_claim`

## Local Development

```bash
# local.settings.json is already created with correct structure
# Fill in the actual values from your deployed infrastructure

# Get storage connection string
az storage account show-connection-string \
  --name dmstfrauddetect \
  --resource-group rg-frauddetect \
  --query connectionString -o tsv

# Get Document Intelligence endpoint and key
az cognitiveservices account show \
  --name doc-intel-frauddetect \
  --resource-group rg-frauddetect \
  --query properties.endpoint -o tsv

az cognitiveservices account keys list \
  --name doc-intel-frauddetect \
  --resource-group rg-frauddetect \
  --query key1 -o tsv

# Update local.settings.json with these values

# Start Azurite (local storage emulator)
azurite --silent --location ./azurite --debug ./azurite/debug.log &

# Run function locally
func start
```

## Fraud Detection Logic

Current fraud indicators detected by the function:
- ✅ **Invoice date before incident date** - Impossible timeline (red flag)
- ✅ **Urgent language patterns** - Keywords like "urgent", "immediate payment"
- ⚠️ **Extensible** - Add more rules in `function_app.py`

### Detection Method

The function performs basic pattern matching after Document Intelligence extraction:

```python
# Date validation
if invoice_date < incident_date:
    fraud_indicators.append("Invoice date before incident date")

# Language analysis
if "urgent" in content_lower or "immediate payment" in content_lower:
    fraud_indicators.append("Urgent language detected")
```

### Future Enhancements

Want more sophisticated detection? The infrastructure is ready to extend:

- **Add Azure AI Search** - Index all claims and detect patterns across multiple documents
- **Add Azure OpenAI** - Use GPT-4 for advanced reasoning about fraud indicators
- **Machine Learning** - Train custom models on historical fraud data
- **Real-time Alerts** - Integrate Azure Monitor for high-risk claim notifications

## Troubleshooting

### Function not triggering

Check blob trigger connection:
```bash
az functionapp config appsettings list \
  --name func-<project-name> \
  --resource-group rg-<project-name>
```

### Document Intelligence errors

Verify endpoint and key:
```bash
curl -X GET "<endpoint>/formrecognizer/info?api-version=2023-07-31" \
  -H "Ocp-Apim-Subscription-Key: <key>"
```

### Storage access errors

Check managed identity has "Storage Blob Data Contributor" role:
```bash
az role assignment list \
  --assignee <function-app-principal-id> \
  --scope <storage-account-id>
```
