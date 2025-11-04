ssh azureuser@$(terraform output -raw web_public_ip)
ping $(terraform output -raw app_private_ip)
ping $(terraform output -raw db_private_ip)