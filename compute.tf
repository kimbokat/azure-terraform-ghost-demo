# -------------------------------
# Network Interfaces
# -------------------------------

# Nginx NIC (Web tier)
resource "azurerm_network_interface" "nginx_nic" {
  name                = "nginx-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nginx-ipcfg"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nginx_public_ip.id
  }
}

# Ghost NIC (App tier)
resource "azurerm_network_interface" "ghost_nic" {
  name                = "ghost-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ghost-ipcfg"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ghost_private_ip
  }
}


# MySQL NIC (DB tier)
resource "azurerm_network_interface" "mysql_nic" {
  name                = "mysql-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "mysql-ipcfg"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.mysql_private_ip
  }
}

# -------------------------------
# Virtual Machines
# -------------------------------

# Nginx VM
resource "azurerm_linux_virtual_machine" "nginx" {
  name                = "nginx-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.nginx_nic.id]
  depends_on            = [azurerm_linux_virtual_machine.ghost] # ensures Ghost is installed before Nginx

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Nginx cloud-init
  custom_data = base64encode(templatefile("${path.module}/cloud-init/nginx.yaml", {
    ghost_ip = var.ghost_private_ip
  }))
}

# Ghost VM
resource "azurerm_linux_virtual_machine" "ghost" {
  name                = "ghost-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.ghost_nic.id]
  depends_on            = [azurerm_linux_virtual_machine.mysql] # ensures MySQL is installed before Ghost

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Ghost cloud-init, pass private ips, public ip and ghost username to .yaml file
  custom_data = base64encode(templatefile("${path.module}/cloud-init/ghost.yaml", {
    ghost_user = "ghostuser"
    ghost_ip   = var.ghost_private_ip
    mysql_ip   = var.mysql_private_ip
    db_pass    = var.mysql_password
    nginx_ip   = azurerm_public_ip.nginx_public_ip.ip_address

  }))

}

# MySQL VM
resource "azurerm_linux_virtual_machine" "mysql" {
  name                = "mysql-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.mysql_nic.id]


  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # MySQL cloud-init
  custom_data = base64encode(templatefile("${path.module}/cloud-init/mysql.yaml", {
    db_pass = var.mysql_password
  }))

}
