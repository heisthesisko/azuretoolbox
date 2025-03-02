#!/bin/bash

# Get the list of available Azure regions
regions=$(az account list-locations --query "[].{Name:name, DisplayName:displayName}" -o tsv)

# Print table header
printf "%-30s %-20s %-10s\n" "Region Name" "Display Name" "Deploy Permission"
printf "%-30s %-20s %-10s\n" "------------------------------" "--------------------" "--------------"

# Loop through regions and check Resource Group creation permission
while IFS=$'\t' read -r name displayName; do
    # Try to create a test resource group (Dry Run)
    check=$(az group create --name "testRG-$name" --location "$name" --only-show-errors --query "properties.provisioningState" -o tsv 2>/dev/null)

    # Set status based on result
    if [[ "$check" == "Succeeded" || "$check" == "Updating" ]]; then
        status="✅"
        # Cleanup test Resource Group to avoid unnecessary charges
        az group delete --name "testRG-$name" --yes --no-wait > /dev/null 2>&1
    else
        status="❌"
    fi

    # Print results
    printf "%-30s %-20s %-10s\n" "$name" "$displayName" "$status"

done <<< "$regions"
