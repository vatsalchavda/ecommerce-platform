# Manage All Services Script
# Usage: .\manage-all.ps1 <--start|--stop|--status|--help>
# Example: .\manage-all.ps1 --start

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Action = "--help"
)

# Normalize action (remove -- prefix if present, convert to lowercase)
$Action = $Action.ToLower().TrimStart('-')

# List of all microservices (add new services here as they are created)
$SERVICES = @(
    @{
        name = "Product Service"
        script = "product-service.ps1"
        port = 7070
        enabled = $true
    }
    # Add future services here:
    # @{
    #     name = "Order Service"
    #     script = "order-service.ps1"
    #     port = 8080
    #     enabled = $true
    # }
    # @{
    #     name = "User Service"
    #     script = "user-service.ps1"
    #     port = 8081
    #     enabled = $true
    # }
)

# Shared infrastructure
$KAFKA_CONTAINER = "ecommerce-platform-kafka-1"
$ZOOKEEPER_CONTAINER = "ecommerce-platform-zookeeper-1"

# Color output functions
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

# Help function
function Show-Help {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Manage All Services" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\manage-all.ps1 <--start|--stop|--status|--help>" -ForegroundColor White
    Write-Host ""
    Write-Host "ACTIONS:" -ForegroundColor Yellow
    Write-Host "  --start   - Start all microservices and shared infrastructure" -ForegroundColor White
    Write-Host "  --stop    - Stop all microservices and shared infrastructure" -ForegroundColor White
    Write-Host "  --status  - Show status of all services and infrastructure" -ForegroundColor White
    Write-Host "  --help    - Display this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\manage-all.ps1 --start" -ForegroundColor Gray
    Write-Host "  .\manage-all.ps1 --stop" -ForegroundColor Gray
    Write-Host "  .\manage-all.ps1 --status" -ForegroundColor Gray
    Write-Host ""
    Write-Host "MANAGED SERVICES:" -ForegroundColor Yellow
    $enabledServices = $SERVICES | Where-Object { $_.enabled -eq $true }
    foreach ($service in $enabledServices) {
        Write-Host "  - $($service.name) (port $($service.port))" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "SHARED INFRASTRUCTURE:" -ForegroundColor Yellow
    Write-Host "  - Kafka (port 9092)" -ForegroundColor White
    Write-Host "  - Zookeeper (port 2181)" -ForegroundColor White
    Write-Host ""
    Write-Host "INDIVIDUAL SERVICE MANAGEMENT:" -ForegroundColor Yellow
    Write-Host "  To manage a single service, use its individual script:" -ForegroundColor White
    foreach ($service in $enabledServices) {
        Write-Host "    .\scripts\$($service.script) <--start|--stop|--status>" -ForegroundColor Gray
    }
    Write-Host ""
}

# Check if Docker is running
function Test-DockerRunning {
    try {
        docker ps | Out-Null
        return $true
    } catch {
        Write-Err "Docker is not running. Please start Docker Desktop."
        return $false
    }
}

# Check if a container is running
function Test-ContainerRunning {
    param([string]$ContainerName)
    $running = docker ps --filter "name=$ContainerName" --format "{{.Names}}" 2>$null
    return $running -eq $ContainerName
}

# Start all services
function Start-AllServices {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   Starting All Services" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    # Check Docker
    if (-not (Test-DockerRunning)) {
        exit 1
    }

    # Start shared infrastructure first (Kafka & Zookeeper)
    Write-Info "Starting shared infrastructure (Kafka & Zookeeper)..."
    docker compose up -d 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Kafka and Zookeeper started"
        Start-Sleep -Seconds 3
    } else {
        Write-Err "Failed to start Kafka and Zookeeper"
        exit 1
    }

    Write-Host ""

    # Start each enabled service
    $enabledServices = $SERVICES | Where-Object { $_.enabled -eq $true }
    foreach ($service in $enabledServices) {
        Write-Info "Starting $($service.name)..."

        $scriptPath = Join-Path $PSScriptRoot $service.script
        if (Test-Path $scriptPath) {
            & $scriptPath start
        } else {
            Write-Warn "Script not found: $($service.script) - skipping"
        }

        Write-Host ""
    }

    Write-Host "========================================" -ForegroundColor Green
    Write-Success "All services started!"
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Info "Next steps for each service:"
    Write-Host "  1. Navigate to service directory" -ForegroundColor Yellow
    Write-Host "  2. Build: mvn clean install -DskipTests" -ForegroundColor Yellow
    Write-Host "  3. Run:   mvn spring-boot:run" -ForegroundColor Yellow
    Write-Host ""
}

# Stop all services
function Stop-AllServices {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "   Stopping All Services" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""

    # Stop each enabled service
    $enabledServices = $SERVICES | Where-Object { $_.enabled -eq $true }
    foreach ($service in $enabledServices) {
        Write-Info "Stopping $($service.name)..."

        $scriptPath = Join-Path $PSScriptRoot $service.script
        if (Test-Path $scriptPath) {
            & $scriptPath stop
        } else {
            Write-Warn "Script not found: $($service.script) - skipping"
        }

        Write-Host ""
    }

    # Stop shared infrastructure (Kafka & Zookeeper)
    Write-Info "Stopping shared infrastructure (Kafka & Zookeeper)..."
    docker compose down 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Kafka and Zookeeper stopped"
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Success "All services stopped!"
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
}

# Show status of all services
function Show-AllStatus {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   All Services - Status" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Shared Infrastructure Status
    Write-Host "SHARED INFRASTRUCTURE:" -ForegroundColor Yellow
    Write-Host ""

    $kafkaRunning = Test-ContainerRunning $KAFKA_CONTAINER
    if ($kafkaRunning) {
        Write-Success "Kafka: Running (port 9092)"
    } else {
        Write-Warn "Kafka: Not running"
    }

    $zookeeperRunning = Test-ContainerRunning $ZOOKEEPER_CONTAINER
    if ($zookeeperRunning) {
        Write-Success "Zookeeper: Running (port 2181)"
    } else {
        Write-Warn "Zookeeper: Not running"
    }

    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""

    # Each Service Status
    $enabledServices = $SERVICES | Where-Object { $_.enabled -eq $true }
    foreach ($service in $enabledServices) {
        Write-Host "$($service.name.ToUpper()):" -ForegroundColor Yellow
        Write-Host ""

        $scriptPath = Join-Path $PSScriptRoot $service.script
        if (Test-Path $scriptPath) {
            & $scriptPath status
        } else {
            Write-Warn "Script not found: $($service.script)"
            Write-Host ""
        }

        if ($service -ne $enabledServices[-1]) {
            Write-Host "----------------------------------------" -ForegroundColor Cyan
            Write-Host ""
        }
    }

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
if ($Action -eq "help" -or $Action -eq "h") {
    Show-Help
    exit 0
}

switch ($Action) {
    "start" {
        Start-AllServices
    }
    "stop" {
        Stop-AllServices
    }
    "status" {
        Show-AllStatus
    }
    default {
        Write-Err "Invalid action: --$Action"
        Write-Host ""
        Show-Help
        exit 1
    }
}

