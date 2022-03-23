az login

az account show

az account list --all --output table

az account set --subscription "xxxxxxxxxxxxxxxxxx"

az group create --name myResourceGroup --location westeurope

az vm create \
    --resource-group myResourceGroup \
    --name myVM \
    --image UbuntuLTS \
    --admin-username andrei \
    --generate-ssh-keys

az vm extension set \
    --publisher Microsoft.Azure.ActiveDirectory.LinuxSSH \
    --name AADLoginForLinux \
    --resource-group myResourceGroup \
    --vm-name myVM