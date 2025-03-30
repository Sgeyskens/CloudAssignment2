# CloudAssignment2

## Cloud Assignment 2

This project automates the deployment of a containerized application to Azure using Bicep and PowerShell.

### Prerequisites
Before you begin, ensure you have the following installed:
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Docker](https://www.docker.com/get-started)
- PowerShell (Windows, or [PowerShell Core](https://github.com/PowerShell/PowerShell) for macOS/Linux)

### Deployment Steps

1. **Clone the repository**
   ```sh
   git clone <repository-url>
   cd <repository-folder>
   ```

2. **Download and install Azure CLI** if not already installed.

3. **Login to Azure using Azure CLI**
   ```sh
   az login
   ```

4. **Execute the PowerShell deployment script**
   ```sh
   powershell -ExecutionPolicy Bypass -File .\main.ps1
   ```
   This script will:
   - Deploy the required Azure resources using Bicep
   - Build and push the Docker image to Azure Container Registry
   - Deploy the container application

5. **Test the deployed container application**
   - Retrieve the public IP address from the Azure Portal or using Azure CLI:
     ```sh
     az container show --resource-group RG-Cloud-WEuro-02 --name containerGroup --query ipAddress.ip --output tsv
     ```
   - Open the IP address in a browser to verify the application is running.

### Notes
- Ensure your Azure subscription has the required permissions to create resources.
- If the container does not start, check Azure logs:
  ```sh
  az container logs --resource-group RG-Cloud-WEuro-02 --name containerGroup
  ```
- Delete resources after testing to avoid unnecessary costs:
  ```sh
  az group delete --name RG-Cloud-WEuro-02 --yes --no-wait
  ```

### License
This project is licensed under the MIT License.

