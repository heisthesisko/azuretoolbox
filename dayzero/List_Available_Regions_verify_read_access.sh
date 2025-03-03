#!/bin/bash

# Get the list of available Azure regions
regions=$(az account list-locations --query "[].{Name:name, DisplayName:displayName}" -o tsv)

# Print table header
printf "%-30s %-20s %-10s\n" "Region Name" "Display Name" "Read Access"
printf "%-30s %-20s %-10s\n" "------------------------------" "--------------------" "--------------"

# Loop through regions and check read access
while IFS=$'\t' read -r name displayName; do
    # Try to list resource groups in the region (this requires read permissions)
    az group list --query "[?location=='$name']" --output tsv > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        status="✅"
    else
        status="❌"
    fi

    # Print results
    printf "%-30s %-20s %-10s\n" "$name" "$displayName" "$status"

done <<< "$regions"
