#!/bin/bash

echo "Fetching Virtual Networks, Subnets, and NSGs..."
echo "--------------------------------------------------------"
printf "%-25s %-25s %-25s %-25s\n" "VNet Name" "Resource Group" "Subnet Name" "NSG Name"

# Get all VNets
az network vnet list --query "[].{name:name,resourceGroup:resourceGroup}" -o json | jq -c '.[]' | while IFS= read -r vnet; do
    vnet_name=$(echo "$vnet" | jq -r '.name')
    resource_group=$(echo "$vnet" | jq -r '.resourceGroup')

    # Get subnets for the VNet (fetch in the background for speed)
    az network vnet subnet list --vnet-name "$vnet_name" --resource-group "$resource_group" --query "[].{name:name, nsg:id}" -o json | jq -c '.[]' | while IFS= read -r subnet; do
        subnet_name=$(echo "$subnet" | jq -r '.name')
        nsg_id=$(echo "$subnet" | jq -r '.nsg')

        # Extract NSG name if exists
        if [[ "$nsg_id" == "null" ]]; then
            nsg_name="None"
        else
            nsg_name=$(echo "$nsg_id" | awk -F'/' '{print $NF}')
        fi

        # Print the output immediately
        printf "%-25s %-25s %-25s %-25s\n" "$vnet_name" "$resource_group" "$subnet_name" "$nsg_name"
    done &  # Run in parallel
done

# Wait for all background processes to finish before exiting
wait
