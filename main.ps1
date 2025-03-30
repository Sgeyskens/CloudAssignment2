# powershell -ExecutionPolicy Bypass -File .\main.ps1
# Enable error handling
$ErrorActionPreference = "Stop"

Write-Host "Starting deployment..." -ForegroundColor Cyan

try {
    # Deploy Bicep file to Azure
    Write-Host "Deploying Bicep template..." -ForegroundColor Yellow
    az deployment sub create --location westeurope --template-file "Z:\.Schooljaar_2024-25\Cloud_platforms\assigment2\main.bicep"
    Write-Host "Deployment completed!" -ForegroundColor Green

    # Build Docker image
    Write-Host "Building Docker image..." -ForegroundColor Yellow
    cd Z:\.Schooljaar_2024-25\Cloud_platforms\assigment2\
    docker build -t flaskcrudapp .
    Write-Host "Docker build completed!" -ForegroundColor Green

    # Get the Azure Container Registry (ACR) login server
    Write-Host "Retrieving ACR login server..." -ForegroundColor Yellow
    $registry = az acr show --name CRCloudWEuro02 --query "loginServer" --output tsv
    if (-not $registry) {
        throw "Failed to retrieve ACR login server."
    }
    Write-Host "ACR login server: $registry" -ForegroundColor Green

    # Log in to Azure Container Registry
    Write-Host "Logging into Azure Container Registry..." -ForegroundColor Yellow
    az acr login --name CRCloudWEuro02
    Write-Host "ACR login successful!" -ForegroundColor Green

    # Tag the Docker image for ACR
    Write-Host "Tagging Docker image..." -ForegroundColor Yellow
    docker tag flaskcrudapp "$registry/flaskcrudapp:latest"
    Write-Host "Image tagged successfully!" -ForegroundColor Green
 
    # Push the Docker image to ACR
    Write-Host "Pushing Docker image to ACR..." -ForegroundColor Yellow
    docker push "$registry/flaskcrudapp:latest"
    Write-Host "Image push completed!" -ForegroundColor Green

    Write-Host "Deploying bicep container instance..." -ForegroundColor Yellow
    az deployment group create --resource-group RG-Cloud-WEuro-02 --template-file "Z:\.Schooljaar_2024-25\Cloud_platforms\assigment2\main2.bicep"
    Write-Host "Deploying bicep container instance completed!" -ForegroundColor Green
    
    Write-Host "Deployment and Docker image upload completed successfully!" -ForegroundColor Cyan


}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}

# Pause to allow viewing of output
Read-Host "Press Enter to exit"


# PowerShell script to automate Azure deployment and Docker image upload
# Execution: Bypass execution policy to allow running the script
# powershell -ExecutionPolicy Bypass -File .\main.ps1

# Enable error handling: Stops execution if any command fails
$ErrorActionPreference = "Stop"

Write-Host "Starting deployment..." -ForegroundColor Cyan

try {
    # Deploy the Bicep template to Azure at the subscription level
    Write-Host "Deploying Bicep template..." -ForegroundColor Yellow
    az deployment sub create --location westeurope --template-file ".\main.bicep"
    Write-Host "Deployment completed!" -ForegroundColor Green

    # Build the Docker image with the name "flaskcrudapp"
    Write-Host "Building Docker image..." -ForegroundColor Yellow
    docker build -t flaskcrudapp .
    Write-Host "Docker build completed!" -ForegroundColor Green

    # Retrieve the login server URL of the Azure Container Registry (ACR)
    Write-Host "Retrieving ACR login server..." -ForegroundColor Yellow
    $registry = az acr show --name CRCloudWEuro02 --query "loginServer" --output tsv
    if (-not $registry) {
        throw "Failed to retrieve ACR login server."
    }
    Write-Host "ACR login server: $registry" -ForegroundColor Green

    # Authenticate to Azure Container Registry
    Write-Host "Logging into Azure Container Registry..." -ForegroundColor Yellow
    az acr login --name CRCloudWEuro02
    Write-Host "ACR login successful!" -ForegroundColor Green

    # Tag the built Docker image for pushing to ACR
    Write-Host "Tagging Docker image..." -ForegroundColor Yellow
    docker tag flaskcrudapp "$registry/flaskcrudapp:latest"
    Write-Host "Image tagged successfully!" -ForegroundColor Green
 
    # Push the tagged Docker image to ACR
    Write-Host "Pushing Docker image to ACR..." -ForegroundColor Yellow
    docker push "$registry/flaskcrudapp:latest"
    Write-Host "Image push completed!" -ForegroundColor Green

    # Deploy the second Bicep template (for the container instance)
    Write-Host "Deploying Bicep container instance..." -ForegroundColor Yellow
    az deployment group create --resource-group RG-Cloud-WEuro-02 --template-file ".\main2.bicep"
    Write-Host "Deploying Bicep container instance completed!" -ForegroundColor Green
    
    Write-Host "Deployment and Docker image upload completed successfully!" -ForegroundColor Cyan
}
catch {
    # Handle errors and display them in red
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}

# Pause the script execution to allow the user to review the output
Read-Host "Press Enter to exit"
