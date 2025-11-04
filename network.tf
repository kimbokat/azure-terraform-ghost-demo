# Virtual Network
# -------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# -------------------------------
# Subnets
# -------------------------------
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_web]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_app]
}

resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_db]
}

# -------------------------------
# NAT Gateway for private subnets
# -------------------------------

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat_ip" {
  name                = "ghost-nat-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_nat_gateway" "nat" {
  name                = "ghost-nat"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_ip.id
}

# Associate NAT Gateway with app + db subnets
resource "azurerm_subnet_nat_gateway_association" "app_nat" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "db_nat" {
  subnet_id      = azurerm_subnet.db.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

# -------------------------------
# Public IP for Nginx VM
# -------------------------------
resource "azurerm_public_ip" "nginx_public_ip" {
  name                = "nginx-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
