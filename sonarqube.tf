# Network for SonarQube VM
resource "azurerm_virtual_network" "sonarqube_vnet" {
  name                = "sonarqube-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "sonarqube_subnet" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.sonarqube_vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_public_ip" "sonarqube_pip" {
  name                = "sonarqube-pip"
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "sonarqube_nsg" {
  name                = "sonarqube-nsg"
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SonarQube"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "sonarqube_nic" {
  name                = "sonarqube-nic"
  location            = "Central India"
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sonarqube_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sonarqube_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "sonarqube_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.sonarqube_nic.id
  network_security_group_id = azurerm_network_security_group.sonarqube_nsg.id
}

resource "azurerm_linux_virtual_machine" "sonarqube_vm" {
  name                = "sonarqube-insurance"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = "Central India"
  size                = "Standard_B2s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.sonarqube_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y ca-certificates curl gnupg
              sudo install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              sudo chmod a+r /etc/apt/keyrings/docker.gpg

              echo \
                "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              
              sudo apt-get update
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              sysctl -w vm.max_map_count=262144
              echo "vm.max_map_count=262144" >> /etc/sysctl.conf

              docker run -d --name sonarqube -p 9000:9000 sonarqube:latest
              EOF
  )
}

output "sonarqube_public_ip" {
  value = azurerm_public_ip.sonarqube_pip.ip_address
}
