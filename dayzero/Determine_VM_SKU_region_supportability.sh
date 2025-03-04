#!/bin/bash


echo "Fetching available VM SKUs..."
vm_skus=$(az vm list-sizes --location eastus --query "[].{Name:name}" -o tsv 2>/dev/null)

# Check if VM SKU retrieval was successful
if [ -z "$vm_skus" ]; then
    echo "Error retrieving VM SKUs. Ensure you have access to query VM sizes in Azure."
    exit 1
fi

# Display VM SKU options for selection
echo "Available VM SKUs:"
select selected_sku in $vm_skus; do
    if [ -n "$selected_sku" ]; then
        echo "You selected: $selected_sku"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Get the list of available Azure regions
regions=$(az account list-locations --query "[].{Name:name, DisplayName:displayName}" -o tsv)

# Print table header
printf "%-30s %-20s %-10s\n" "Region Name" "Display Name" "Supports SKU"
printf "%-30s %-20s %-10s\n" "------------------------------" "--------------------" "--------------"

# Loop through regions and check if the selected VM SKU is available
while IFS=$'\t' read -r name displayName; do
    # Check if the selected SKU is available in the region
    sku_available=$(az vm list-sizes --location "$name" --query "[?name=='$selected_sku'].name" -o tsv 2>/dev/null)

    if [ -n "$sku_available" ]; then
        status="✅"
    else
        status="❌"
    fi

    # Print results
    printf "%-30s %-20s %-10s\n" "$name" "$displayName" "$status"

done <<< "$regions"
