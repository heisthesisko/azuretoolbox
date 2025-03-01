#!/bin/bash

# Define US regions
us_regions=("eastus" "eastus2" "westus" "westus2" "centralus" "northcentralus" "southcentralus" "westus3")

echo "Fetching available VM SKUs in US-based regions..."

# Loop through each US region and list available VM sizes
for region in "${us_regions[@]}"; do
    echo -e "\nRegion: $region"
    echo "----------------------"
    
    az vm list-sizes --location $region --output table
done
