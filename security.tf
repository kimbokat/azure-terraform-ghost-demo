# -----------------------
# NSG for Web Subnet (nginx)
# -----------------------
resource "azurerm_network_security_group" "nsg_web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "web_allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*" # From internet
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_web.name
}

resource "azurerm_network_security_rule" "web_allow_http" {
  name                        = "Allow-HTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*" # From internet
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_web.name
}

resource "azurerm_subnet_network_security_group_association" "assoc_web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}

#-------------------
# NSG for App subnet
#--------------------
resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Allow SSH from Web subnet only
resource "azurerm_network_security_rule" "app_ssh" {
  name                        = "Allow-SSH-Web"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.subnet_web
  destination_address_prefix  = azurerm_linux_virtual_machine.ghost.private_ip_address
  network_security_group_name = azurerm_network_security_group.nsg_app.name
  resource_group_name         = azurerm_resource_group.rg.name
}

# Allow Ghost port 2368 from Web if you want direct access
resource "azurerm_network_security_rule" "app_ghost" {
  name                        = "Allow-Ghost-Web"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "2368"
  source_address_prefix       = var.subnet_web # Allow access from web only
  destination_address_prefix  = azurerm_linux_virtual_machine.ghost.private_ip_address
  network_security_group_name = azurerm_network_security_group.nsg_app.name
  resource_group_name         = azurerm_resource_group.rg.name
}

# Associate NSG with App subnet
resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}


# -----------------------
# NSG for DB Subnet (mysql)
# -----------------------
resource "azurerm_network_security_group" "nsg_db" {
  name                = "nsg-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Allow MySQL port 3306 only from App subnet
resource "azurerm_network_security_rule" "db_mysql" {
  name                        = "Allow-MySQL-App"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = var.subnet_app # Allow access from app only
  destination_address_prefix  = azurerm_linux_virtual_machine.mysql.private_ip_address
  network_security_group_name = azurerm_network_security_group.nsg_db.name
  resource_group_name         = azurerm_resource_group.rg.name
}

# Associate NSG with DB subnet
resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}