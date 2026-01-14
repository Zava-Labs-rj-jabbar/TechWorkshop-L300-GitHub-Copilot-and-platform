# GitHub Actions Deployment Setup

## Overview
This repository uses GitHub Actions to build a Docker container from the .NET application and deploy it to Azure App Service.

## Deployment Information

**Your Resources:**
- **Container Registry:** `azacrll5a5ozlqzo3c.azurecr.io`
- **App Service:** `azasvll5a5ozlqzo3c`
- **Resource Group:** `techworkshop-ghcopilot-rg`
- **Subscription:** `5368b2d9-6684-421e-919a-cf0d7be0b6a3`

## Required Configuration

### GitHub Secrets
Add these secrets to your GitHub repository settings (`Settings > Secrets and variables > Actions`):

| Secret | Description | Your Value |
|--------|-------------|------------|
| `REGISTRY_LOGIN_SERVER` | Azure Container Registry login server | `azacrll5a5ozlqzo3c.azurecr.io` |
| `REGISTRY_USERNAME` | Azure Container Registry username | Get from ACR Access keys |
| `REGISTRY_PASSWORD` | Azure Container Registry password | Get from ACR Access keys |
| `AZURE_CREDENTIALS` | Azure Service Principal credentials (JSON format) | ✅ Already configured |

### GitHub Variables
Add these variables to your GitHub repository settings (`Settings > Secrets and variables > Actions`):

| Variable | Description | Your Value |
|----------|-------------|------------|
| `APP_SERVICE_NAME` | Name of your Azure App Service | `azasvll5a5ozlqzo3c` |

## How to Get the Values

### Azure Container Registry Credentials
1. Navigate to your Container Registry in the Azure Portal:
   - Go to: https://portal.azure.com
   - Search for: `azacrll5a5ozlqzo3c`
2. Click **Access keys** in the left menu
3. Enable **Admin user** toggle
4. Copy:
   - **Login server**: `azacrll5a5ozlqzo3c.azurecr.io` (use for `REGISTRY_LOGIN_SERVER`)
   - **Username**: (use for `REGISTRY_USERNAME`)
   - **password**: (use for `REGISTRY_PASSWORD`)

### Azure Service Principal
✅ **Already configured** - You've added the `AZURE_CREDENTIALS` secret

## Quick Setup Checklist

- [ ] Add `REGISTRY_LOGIN_SERVER` secret = `azacrll5a5ozlqzo3c.azurecr.io`
- [ ] Add `REGISTRY_USERNAME` secret (from ACR Access keys)
- [ ] Add `REGISTRY_PASSWORD` secret (from ACR Access keys)
- [x] Add `AZURE_CREDENTIALS` secret (already done)
- [ ] Add `APP_SERVICE_NAME` variable = `azasvll5a5ozlqzo3c`

## First Run

Once all secrets and variables are configured:
1. Push to `main` branch, OR
2. Go to **Actions** tab → **Build and Deploy** → **Run workflow**

The workflow will:
1. Build your .NET app as a Docker container
2. Push to Azure Container Registry
3. Deploy to App Service

View your deployed app at: `https://azasvll5a5ozlqzo3c.azurewebsites.net`
