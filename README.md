# Terraform: Ghost 3-Tier Deployment on Azure
[![License: MIT](https://img.shields.io/badge/License-MIT-teal.svg)](./LICENSE)
[![Azure](https://img.shields.io/badge/Microsoft%20Azure-Cloud-0089D6)](https://azure.microsoft.com/)
[![Terraform](https://img.shields.io/badge/Terraform-1.13.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Ghost CMS](https://img.shields.io/badge/Ghost-6.6.1-15171A?logo=ghost&logoColor=white)](https://ghost.org/)

**Verified Stack:**  
Ubuntu 22.04 LTS · Terraform 1.13.0 · AzureRM 3.117.1 · NGINX 1.18.0 · Ghost 6.6.1 (CLI 1.28.3) · MySQL 8.0.43

---
## Overview

When I started learning Infrastructure as Code, I couldn't find a clear guide using the tools I wanted to explore. I built this project to bridge that gap. Demonstrating how to use **Terraform** to deploy a production-like three-tier architecture on **Microsoft Azure** while hosting a real application ([**Ghost CMS**](https://ghost.org/)).

**What you'll learn:**
- Provisioning multi-tier cloud infrastructure with Terraform
- Implementing network security with NSGs and private subnets
- Automating VM configuration using cloud-init
- Managing SSH access patterns for private infrastructure
- Working with Azure CLI and Linux command line

> [!NOTE]
> **Disclaimer:**  
> This project is provided for educational and informational purposes only. While built with care, no warranties are made regarding completeness, reliability, or accuracy. 
> Any actions taken based on this material are strictly at your own risk. The code is provided "as is" under the MIT License. See [LICENSE](./LICENSE) for details.

## Three-tier infrastructure

You’ll deploy a real web app (Ghost CMS) using [Terraform to provision infrastructure automatically.](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/infrastructure-as-code?in=terraform%2Fazure-get-started)
The environment follows a [**3-tier architecture**](https://www.ibm.com/think/topics/three-tier-architecture) with clear separation between presentation, logic, and data layers.

| Tier | Network Scope | Component | Description | Key Concept
|------|----------------|------------|--------------|---------
| **Web Tier** | Public | **NGINX** | Entry point and reverse proxy for incoming HTTP traffic | Internet-facing access with public IP |
| **Application Tier** | Private | **Ghost CMS** | Hosts the Ghost blog and serves dynamic content behind NGINX | Private subnet with NAT for outbound access |
| **Database Tier** | Private | **MySQL** | Stores Ghost's content, and configuration data | Restricted access via NSG rules |



## 🏗️ Architecture

### Azure resources

- **Resource Group**
- **Virtual Network (VNet)** with 3 subnets:
  - `web-subnet` (public)
  - `app-subnet` (private)
  - `db-subnet` (private)
- **Virtual Machines (VMs)** one per tier:
  - ``nginx-vm`` (web tier)
  - ``ghost-vm`` (application tier)
  - ``mysql-vm`` (database tier)
- **Network Security Groups (NSGs)** for tier-specific firewall rules
- **NAT Gateway** for outbound Internet access from private subnets
- **Cloud-init** scripts for VM bootstrapping (installing NGINX, Ghost, MySQL)

![architecture diagram](architecture_diagram.png)

## 📂 Repository Structure
```
azure-terraform-ghost-demo/
├── main.tf                # Resource group
├── providers.tf           # Provider configuration (Azure)
├── variables.tf           # Input variables
├── network.tf             # VNet + Subnets
├── security.tf            # NSGs + rules
├── compute.tf             # VM + NIC definitions
├── outputs.tf             # Terraform outputs (IP addresses)
├── terraform.tfvars       # Sensitive variables (excluded from Git)
├── .gitignore             # Excludes tfvars, state files, etc.
├── cloud-init/            # Cloud-init scripts
│   ├── ghost.yaml
│   ├── nginx.yaml
│   └── mysql.yaml
└── README.md              # Project documentation and guide

```
Cloud-init YAML files must begin with `#cloud-config` (no space) for Azure to interpret them correctly.

## ⚙️ Requirements
Setup was tested in Windows 11 (local environment)

- Azure subscription (Free, Student, or Pay-as-you-go)
- [Terraform ≥ 1.13.0](https://kodekloud.com/blog/easy-guide-to-install-terraform-on-windows/)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Visual Studio Code](https://code.visualstudio.com/) (+ following extensions)
  + [HashiCorp Terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
  + [YAML by Red Hat](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
- [Windows Terminal (for built-in OpenSSH)](https://apps.microsoft.com/detail/9n0dx20hk701?hl=fi-FI&gl=FI)
- [SSH keypair for VM access](https://docs.exavault.com/using-exavault/users/ssh-key-authentication/creating-an-ssh-key-on-windows)  
  - Default location (Windows): `C:\Users\<User>\.ssh\id_rsa.pub`
  - Terraform variable ssh_public_key_path uses this file by default `(~/.ssh/id_rsa.pub)`

>[!TIP]
> [Azure for Students offers $100 in Azure credits, with no credit card required. Credit is valid for one year.](https://learn.microsoft.com/en-us/azure/education-hub/about-azure-for-students)

## 🚀 Getting Started

### 1. Login and verify Azure account
```bash
az login
az account show
```

### 2. Create `terraform.tfvars` file

In the root of the project created a file named `terraform.tfvars` and add your MySQL password:
```
mysql_password = "your_sql_pass_here"
```
This file contains sensitive data and **should not be committed to GitHub.** Add this to .gitignore (which is already configured in the repo).

### 3. Clone the repository
```bash
git clone https://github.com/<your-username>/azure-terraform-ghost-demo.git
cd azure-terraform-ghost-demo
```

### 4. Initialize Terraform
```bash
terraform init
```
### 5. Format and validate the configuration
Format your Terraform files to ensure consistent style and catch syntax issues
```bash
terraform fmt
terraform validate
```

### 6. Plan and deploy resources

```bash
terraform plan
terraform apply
```
Navigate to the [Azure portal](portal.azure.com) and **Dashboard** to validate deployed resources.



### 7. Destroy resources when done
```bash
terraform destroy
```

## 🔐 SSH Agent Forwarding

This setup uses Nginx VM as a jump host to access private VMs securely.

Private VMs (Ghost & MySQL) have no public IPs. SSH agent forwarding
allows you to "hop" securely from Nginx → Ghost → MySQL.

### Start the SSH agent
```powershell
Start-Service ssh-agent
ssh-add C:\Users\<User>\.ssh\<private-key>

# Verify key is loaded
ssh-add -l 
```

## Testing the VMs

### 1. Connect to Nginx VM
```bash
ssh -A azureuser@<nginx_public_ip>
```

### 2. Connect to Ghost VM
```bash
ssh azureuser@<ghost_private_ip>

```

### 3. Switch to Ghost user
```bash
sudo -u ghostuser -i
```
The Ghost CLI runs as a dedicated user (ghostuser), which is passed to cloud-init. All commands should be executed under it.

Ghost takes about 5 mins to setup. You can check the cloud-init progress with `sudo tail -n 100 /var/log/cloud-init-output.log`

---

### ⚠️ SSH Host Key Warning

> When a VM is re-created (after terraform destroy or re-apply), you may see:
*"WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"*

This is normal, the VM has a new SSH fingerprint.
To fix, remove the old key:
```bash
ssh-keygen -R <vm_ip>
```
## 🔍 Verification & Testing Cheatsheet

Each test verifies a part of the infrastructure.

| Test                                           | Command                                              | Expected Result                                    |
| ---------------------------------------------- | ---------------------------------------------------- | -------------------------------------------------- |
| Cloud-init output | `sudo tail -n 100 /var/log/cloud-init-output.log`    | Shows Ghost installation and setup logs            |
| Cloud-init log (full details)              | `sudo less /var/log/cloud-init.log`                  | Displays all provisioning steps                    |
| Ghost service logs                         | `ghost log` (run as `ghostuser` in `/var/www/ghost`) | Shows live Ghost activity (requests, startup info) |
| Ghost status                               | `ghost ls`                                           | Ghost instance listed as “running”                 |
| Database connection                        | `mysql -h <mysql_private_ip> -u ghost -p` (run `SHOW DATABASES;`)            | `ghost_db` visible in output                       |
| NAT check                                  | `curl -I https://ghost.org` (from Ghost VM)          | `200 OK` confirms outbound Internet access         |
| Website check                              | `curl http://<nginx_public_ip>`                      | Returns Ghost homepage HTML                        |


> [!TIP]  
> These tests validate both **connectivity** and **security**.  
> Passing them means your NSGs, NAT, and subnet rules are correctly implemented and your 3-tier architecture behaves as intended.
>
> Remember to `terraform destroy` when you are done testing and poking around VMs.


## 📈 From Learning to Production

This setup demonstrates core IaC concepts in a working environment. Here's what you'd add to make it production-ready:

**Security & Secrets**
- Migrate MySQL password from local `.tfvars` to [Azure Key Vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) or [Terraform Vault](https://developer.hashicorp.com/vault/tutorials/get-started/learn-terraform)
- Replace public SSH with [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview) for secure VM management

**State & Collaboration**
- Store Terraform state in [Azure Blob Storage](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm) for team access
- Authenticate via Service Principal instead of interactive `az login`

**Operations**
- Add CI/CD with [GitHub Actions](https://resources.github.com/learn/pathways/automation/essentials/building-a-workflow-with-github-actions/) for automated validation
- Implement monitoring via [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/overview) or [Grafana](https://grafana.com/products/cloud/?pg=oss-graf&plcmt=hero-txt)

**Ghost Configuration**
- Configure custom domain with HTTPS/SSL
- Add SMTP server for user registration and password recovery

---

## License

This project is licensed under the [MIT License](https://choosealicense.com/licenses/mit/).  

You’re free to use, modify, and share this code for any purpose, provided you include the original license notice.

The project and all files are provided **as is**, without warranty of any kind. See the [LICENSE](./LICENSE) file for full details.


