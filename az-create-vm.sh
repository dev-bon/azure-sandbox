#!/bin/bash

function server_location {
    echo "Available Azure VM Regions"
    echo ""
    echo "1. East US"
    echo "2. West US"
    echo "3. Australia East"
    echo "4. West Europe"
    echo "5. Germany"
    echo "6. Canada"
    echo ""
    read -p "Select your option:" ans
    case $ans in
        1  )  clear; echo "East US Region Selected"; echo eastus > location; echo westus > paired;;
        2  )  clear; echo "West US Region Selected"; echo westus > location; echo eastus > paired;;
        3  )  clear; echo "Australia East Region Selected"; echo australiaeast > location; echo australiasoutheast > paired;;
        4  )  clear; echo "West Europe Region Selected"; echo westeurope > location; echo northeurope > paired;;
        5  )  clear; echo "Germany Region Selected"; echo germany > location; echo germanynorth > paired;;
        6  )  clear; echo "Canada Region Selected"; echo canada > location; echo canadaeast > paired;;
        "" )  clear; echo "None selected"; sleep 1; server_location;;
        *  )  clear; echo "Invalid option entered"; sleep 1; server_location;;
    esac
}

function server_image {
    echo "Available Azure Operating System Images"
    echo ""
    echo "1. Windows 11 Pro"
    echo "2. Windows 10 Pro"
    echo ""
    read -p "Select your option:" ans
    case $ans in
        1  )  clear; echo "Windows 11 Pro Image Selected"; echo MicrosoftWindowsDesktop:windows-11:win11-22h2-pro:latest > image;;
        2  )  clear; echo "Windows 10 Pro Image Selected"; echo MicrosoftWindowsDesktop:Windows-10:win10-22h2-pro:latest > image;;
        "" )  clear; echo "None selected"; sleep 1; server_image;;
        *  )  clear; echo "Invalid option entered"; sleep 1; server_image;;
    esac
}

function server_size {
    echo "Available Azure VM Sizes"
    echo ""
    echo "1. B2ms - 2CPU/8GB - Highest performance and more ram"
    echo "2. DS2_v2 - 2CPU/7GB - Highest performance"
    echo "3. D2s_v3 - 2CPU/8GB - Slower than B2ms and DS2_v2 but have nested virtualization"
    echo ""
    read -p "Select your option:" ans
    case $ans in
        1  )  clear; echo "B2ms Size Selected"; echo "Standard_B2ms" > size;;
        2  )  clear; echo "DS2_v2 Size Selected"; echo "Standard_DS2_v2" > size;;
        3  )  clear; echo "D2s_v3 Size Selected"; echo "Standard_D2s_v3" > size;;
        "" )  clear; echo "None selected"; sleep 1; server_size;;
        *  )  clear; echo "Invalid option entered"; sleep 1; server_size;;
    esac
}

function check_web_app {
    web=$(az webapp list --query "[].{hostName: defaultHostName, state: state}" --output tsv | grep haivm | cut -f 1)
    echo $web/metrics > site
}

function check_vm {
    echo "⌛  Checking Previous VM..."
    az vm list-ip-addresses -n myVM --output tsv > IP.txt
    [ -s IP.txt ] && bash -c "echo You Already Have Running VM... && az vm list-ip-addresses -n myVM --output table" && goto ask
}

function create_vnet {
    az network vnet create --resource-group $rs --location $location --name myVNet --address-prefixes 10.0.0.0/16 2404:f800:8000:122::/63 --subnet-name myBackendSubnet --subnet-prefixes 10.0.0.0/24 2404:f800:8000:122::/64
}

function create_public_ip {
    az network public-ip create --resource-group $rs --location $location --name myPublicIP-Ipv4 --sku Standard --version IPv4 --zone 1
    az network public-ip create --resource-group $rs --location $location --name myPublicIP-Ipv6 --sku Standard --version IPv6 --zone 1
}

function create_network_sg {
    az network nsg create --resource-group $rs --location $location --name myNSG
}

function create_network_sg_rules {
    az network nsg rule create --resource-group $rs --nsg-name myNSG --name myNSGRuleSSH --protocol '*' --direction inbound --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 200
    
    az network nsg rule create --resource-group $rs --nsg-name myNSG --name myNSGRuleRDP --protocol '*' --direction inbound --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range 3389 --access allow --priority 201
    
    az network nsg rule create --resource-group $rs --nsg-name myNSG --name myNSGRuleAllOUT --protocol '*' --direction outbound --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range '*' --access allow --priority 200
}

function create_network_interface {
    az network nic create --resource-group $rs --location $location --name myNIC1 --vnet-name myVNet --subnet myBackEndSubnet --network-security-group myNSG --public-ip-address myPublicIP-IPv4
}

function create_ipv6_config {
    az network nic ip-config create --resource-group $rs --name myIPv6config --nic-name myNIC1 --private-ip-address-version IPv6 --vnet-name myVNet --subnet myBackendSubnet --public-ip-address myPublicIP-IPv6
}

function create_vm {
    image=$(cat image)
    size=$(cat size)
    
    az vm create --resource-group $rs --location $location --name myVM --nics myNIC1 --public-ip-sku Standard --size $size --image $image --admin-username azureuser --admin-password WindowsPassword@001 --nic-delete-option delete --os-disk-delete-option delete --out table
}

function finalize_setup {
    CF=$(curl -s --connect-timeout 5 --max-time 5 $URL | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u | sed s/'http[s]\?:\/\/'//)
    echo -n $CF > CF
    cat CF | grep trycloudflare.com > CF2
    if [ -s CF2 ]; then echo OK; else echo -en "\r Checking .     $i 🌐 ";sleep 0.1;echo -en "\r Checking ..    $i 🌐 ";sleep 0.1;echo -en "\r Checking ...   $i 🌐 ";sleep 0.1;echo -en "\r Checking ....  $i 🌐 ";sleep 0.1;echo -en "\r Checking ..... $i 🌐 ";sleep 0.1;echo -en "\r Checking     . $i 🌐 ";sleep 0.1;echo -en "\r Checking  .... $i 🌐 ";sleep 0.1;echo -en "\r Checking   ... $i 🌐 ";sleep 0.1;echo -en "\r Checking    .. $i 🌐 ";sleep 0.1;echo -en "\r Checking     . $i 🌐 ";sleep 0.1 && finalize_setup; fi
    CF=$(curl -s $URL | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u | sed s/'http[s]\?:\/\/'//) && echo $CF > CF
    
    timeout 10s az vm run-command invoke --command-id RunPowerShellScript --name myVM -g $rs --scripts "cd C:\PerfLogs ; cmd /c curl -L -s -k -O https://raw.githubusercontent.com/kmille36/thuonghai/master/katacoda/AZ/alive.bat ; (gc alive.bat) -replace 'URLH', '$URL' | Out-File -encoding ASCII alive.bat ; (gc alive.bat) -replace 'CF', '$CF' | Out-File -encoding ASCII alive.bat ; cmd /c curl -L -s -k -O https://raw.githubusercontent.com/kmille36/thuonghai/master/katacoda/AZ/config.json ; (gc config.json) -replace 'CF', '$CF' | Out-File -encoding ASCII config.json ; cmd /c curl -L -k -O https://raw.githubusercontent.com/kmille36/thuonghai/master/katacoda/AZ/internet.bat ; cmd /c internet.bat" --out table
    
    echo "Your RDP is READY TO USE !!! "
}

function rdp_info {
    az vm open-port --resource-group $rs --name myVM --port '*'
    
    IP=$(az vm show -d -g $rs -n myVM --query publicIps -o tsv)
    echo "Public IP: $IP"
    echo "Username: azureuser"
    echo "Password: WindowsPassword@001"
    
    echo "🖥️  Run Command Setup Internet In Process... (10s)"
}

function ping_cf {
    URL=$(cat site)
    CF=$(curl -s --connect-timeout 5 --max-time 5 $URL | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u | sed s/'http[s]\?:\/\/'//)
    echo -n $CF > CF
    cat CF | grep trycloudflare.com > CF2
    if [ -s CF2 ]; then rdp_info; else echo -en "\r Checking .     $i 🌐 ";sleep 0.1;echo -en "\r Checking ..    $i 🌐 ";sleep 0.1;echo -en "\r Checking ...   $i 🌐 ";sleep 0.1;echo -en "\r Checking ....  $i 🌐 ";sleep 0.1;echo -en "\r Checking ..... $i 🌐 ";sleep 0.1;echo -en "\r Checking     . $i 🌐 ";sleep 0.1;echo -en "\r Checking  .... $i 🌐 ";sleep 0.1;echo -en "\r Checking   ... $i 🌐 ";sleep 0.1;echo -en "\r Checking    .. $i 🌐 ";sleep 0.1;echo -en "\r Checking     . $i 🌐 ";sleep 0.1 && ping_cf; fi
}

function configure_resource {
    az group list | jq -r '.[0].name' > rs
    rs=$(cat rs)
    
    az webapp list --resource-group $rs --output table |  grep -q haivm && check_web_app
    
    echo $RANDOM$RANDOM > number
    NUMBER=$(cat number)
    echo "haivm$NUMBER$NUMBER.azurewebsites.net/metrics" > site
    
    location=$(cat location)
    paired=$(cat paired)
    
    echo "az appservice plan create --name myAppServicePlan$NUMBER$NUMBER --resource-group $rs --location $paired --sku F1 --is-linux --output none && az webapp create --resource-group $rs --plan myAppServicePlan$NUMBER$NUMBER --name haivm$NUMBER$NUMBER --deployment-container-image-name docker.io/thuonghai2711/v2ray-azure-web:latest --output none" > webapp.sh
    nohup bash webapp.sh  &>/dev/null &
    
    #check_vm
}

# Start process by setting up required Azure VM details

# Set Azure VM server location
sleep 1s
clear
server_location

# Set Azure VM server image
sleep 1s
clear
server_image

# Set Azure VM server size
sleep 1s
clear
server_size

# Configure Azure sandbox resource group
sleep 1s
clear
echo "Configuring Azure sandbox resource group..."
configure_resource

# Create dual stack virtual network
sleep 1s
clear
echo "Creating a dual stack virtual network..."
create_vnet

# Create public IP addresses
sleep 1s
clear
echo "Creating public IP addresses..."
create_public_ip

# Create network security group
sleep 1s
clear
echo "Creating network security group..."
create_network_sg

# Create network security group rules
sleep 1s
clear
echo "Creating network security group rules..."
create_network_sg_rules

# Create network interface
sleep 1s
clear
echo "Creating network interface..."
create_network_interface

#Create IPv6 configuration
sleep 1s
clear
echo "Creating IPv6 IP configuration..."
create_ipv6_config

# Create virtual machine
sleep 1s
clear
echo "Creating virtual machine..."
create_vm

# Ping Cloudflare
sleep 1s
clear
echo "Pinging Cloudflare..."
ping_cf

# Show Created VM RDP Info
sleep 1s
clear
rdp_info

# Finalize and run shell script command
sleep 1s
echo "Finalizing setup..."
finalize_setup