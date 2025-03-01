#!/bin/bash

# Get the subscription ID
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)

echo "Fetching available Azure regions with deployment permissions..."

# List available locations
declare -A region_status
while read -r region; do
    status=$(az resource invoke-action --action list --namespace Microsoft.Resources --resource-type deployments --id "/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Resources/locations/$region" --query "error" -o tsv 2>/dev/null)
    if [ -z "$status" ]; then
        region_status[$region]="✅ Deployable"
    else
        region_status[$region]="❌ No Deployment Permission"
    fi
done < <(az account list-locations --query "[].name" -o tsv)

# Display results
echo -e "\nAvailable Regions and Deployment Status:"
echo "--------------------------------------------"
for region in "${!region_status[@]}"; do
    echo "$region - ${region_status[$region]}"
done
