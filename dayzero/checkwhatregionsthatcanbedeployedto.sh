#!/bin/bash

# Get the subscription ID
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)

echo "Fetching available Azure regions with deployment permissions..."
echo

# List available locations
declare -A region_status
regions=($(az account list-locations --query "[].name" -o tsv))

# Use a counter for dynamic updates
total_regions=${#regions[@]}
counter=0

for region in "${regions[@]}"; do
    ((counter++))
    printf "\rChecking region: %-20s [%d/%d]" "$region" "$counter" "$total_regions"

    status=$(az resource invoke-action --action list --namespace Microsoft.Resources --resource-type deployments --id "/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Resources/locations/$region" --query "error" -o tsv 2>/dev/null)
    
    if [ -z "$status" ]; then
        region_status[$region]="✅ Deployable"
    else
        region_status[$region]="❌ No Deployment Permission"
    fi
done

# Clear the line after completion
printf "\n\n"

# Display results
echo "Available Regions and Deployment Status:"
echo "--------------------------------------------"
for region in "${!region_status[@]}"; do
    echo "$region - ${region_status[$region]}"
done
