# -----------------------
# Web Tier (nginx)
# -----------------------
output "web_public_ip" {
  description = "Public IP of the nginx (web) VM"
  value       = azurerm_public_ip.nginx_public_ip.ip_address
}

# -----------------------
# App Tier (ghost)
# -----------------------
output "app_private_ip" {
  description = "Private IP of the Ghost (app) VM"
  value       = azurerm_linux_virtual_machine.ghost.private_ip_address
}

# -----------------------
# DB Tier (mysql)
# -----------------------
output "db_private_ip" {
  description = "Private IP of the MySQL (db) VM"
  value       = azurerm_linux_virtual_machine.mysql.private_ip_address
}
