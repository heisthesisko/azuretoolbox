#!/bin/bash                                                                                                                                                                                                    

# Define US regions to check
us_regions=("eastus" "eastus2" "westus" "westus2" "centralus" "northcentralus" "southcentralus" "westus3")

# Define the VM SKU to check
vm_sku="Standard_D2s_v3"

echo "Checking availability of $vm_sku in US-based regions..."

# Loop through each US region and check SKU availability
for region in "${us_regions[@]}"; do
    echo -n "Region: $region -> "
    
    # Check if the SKU is available in the region
    available=$(az vm list-skus --location $region --query "[?name=='$vm_sku'].name" -o tsv)

    if [[ -n "$available" ]]; then
        echo "✅ Allowed"
    else
        echo "❌ Not Allowed"
    fi
done
