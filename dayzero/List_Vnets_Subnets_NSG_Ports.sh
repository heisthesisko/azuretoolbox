#!/bin/bash

# Fetch all VNets in the subscription
vnets=$(az network vnet list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location}" -o tsv)

# Print table header
printf "%-25s %-20s %-20s %-25s %-35s %-10s %-10s %-15s\n" "VNet Name" "Resource Group" "Location" "Subnet Name" "Network Security Group" "Port" "Protocol" "Access"
printf "%-25s %-20s %-20s %-25s %-35s %-10s %-10s %-15s\n" "-------------------------" "--------------------" "--------------------" "-------------------------" "-----------------------------------" "----------" "---------" "--------------"

# Loop through each VNet
while IFS=$'\t' read -r vnetName resourceGroup location; do
    # Fetch subnets for the current VNet
    subnets=$(az network vnet subnet list --vnet-name "$vnetName" --resource-group "$resourceGroup" --query "[].{Name:name, NSG:networkSecurityGroup.id}" -o tsv)

    # If no subnets found, print VNet info with "No subnets"
    if [ -z "$subnets" ]; then
        printf "%-25s %-20s %-20s %-25s %-35s %-10s %-10s %-15s\n" "$vnetName" "$resourceGroup" "$location" "No subnets" "N/A" "N/A" "N/A" "N/A"
        continue
    fi

    # Loop through each subnet
    while IFS=$'\t' read -r subnetName nsgId; do
        # Extract NSG name from NSG ID (if available)
        if [ -n "$nsgId" ]; then
            nsgName=$(echo "$nsgId" | awk -F'/' '{print $NF}')
        else
            nsgName="No NSG"
        fi

        # If the subnet has no NSG, print row without NSG details
        if [ "$nsgName" == "No NSG" ]; then
            printf "%-25s %-20s %-20s %-25s %-35s %-10s %-10s %-15s\n" "$vnetName" "$resourceGroup" "$location" "$subnetName" "No NSG" "N/A" "N/A" "N/A"
            continue
        fi

        # Fetch inbound security rules for the NSG
        nsgRules=$(az network nsg rule list --nsg-name "$nsgName" --resource-group "$resourceGroup" --query "[].{Port:destinationPortRange, Protocol:protocol, Access:access}" -o tsv 2>/dev/null)

        # If no inbound rules are found, print NSG details with "No Rules"
        if [ -z "$nsgRules" ]; then
            printf "%-25s %-20s %-20s %-25s %-35s %-10s %-10s %-15s\n" "$vnetName" "$resourceGroup" "$location" "$subnetName" "$nsgName" "No Rules" "N/A" "N/A"
            continue
        fi

        # Loop through each inbound security rule
        while IFS=$'\t' read -r port protocol access; do
            printf "%-25s %-20s %-20s %-25s %-35s %-10s %-10s %-15s\n" "$vnetName" "$resourceGroup" "$location" "$subnetName" "$nsgName" "$port" "$protocol" "$access"
        done <<< "$nsgRules"

    done <<< "$subnets"

done <<< "$vnets"
