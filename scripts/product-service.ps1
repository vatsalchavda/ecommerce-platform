# Product Service Management Script
# Usage: .\product-service.ps1 <--start|--stop|--status|--help>
# Example: .\product-service.ps1 --start

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Action = "--help"
)

# Normalize action (remove -- prefix if present, convert to lowercase)
$Action = $Action.ToLower().TrimStart('-')

# Service Configuration
$SERVICE_NAME = "Product Service"
$SERVICE_PORT = 7070
$MONGO_CONTAINER = "product-mongodb"
$MONGO_PORT = 27018
$MONGO_IMAGE = "mongo:7.0"
$SWAGGER_URL = "http://localhost:${SERVICE_PORT}/swagger-ui.html"

# Color output functions
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

# Help function
function Show-Help {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   $SERVICE_NAME - Management Script" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\product-service.ps1 <--start|--stop|--status|--help>" -ForegroundColor White
    Write-Host ""
    Write-Host "ACTIONS:" -ForegroundColor Yellow
    Write-Host "  --start   - Start all infrastructure (MongoDB, Kafka, Zookeeper)" -ForegroundColor White
    Write-Host "  --stop    - Stop service infrastructure (MongoDB only)" -ForegroundColor White
    Write-Host "  --status  - Show status of all components" -ForegroundColor White
    Write-Host "  --help    - Display this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\product-service.ps1 --start" -ForegroundColor Gray
    Write-Host "  .\product-service.ps1 --stop" -ForegroundColor Gray
    Write-Host "  .\product-service.ps1 --status" -ForegroundColor Gray
    Write-Host ""
    Write-Host "INFRASTRUCTURE:" -ForegroundColor Yellow
    Write-Host "  MongoDB:    $MONGO_CONTAINER (port $MONGO_PORT)" -ForegroundColor White
    Write-Host "  Kafka:      ecommerce-platform-kafka-1 (port 9092)" -ForegroundColor White
    Write-Host "  Zookeeper:  ecommerce-platform-zookeeper-1 (port 2181)" -ForegroundColor White
    Write-Host "  App Port:   $SERVICE_PORT" -ForegroundColor White
    Write-Host "  Swagger UI: $SWAGGER_URL" -ForegroundColor White
    Write-Host ""
    Write-Host "NEXT STEPS AFTER START:" -ForegroundColor Yellow
    Write-Host "  1. Build:   mvn clean install -DskipTests" -ForegroundColor Gray
    Write-Host "  2. Run:     mvn spring-boot:run" -ForegroundColor Gray
    Write-Host "  3. Test:    $SWAGGER_URL" -ForegroundColor Gray
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

# Start Kafka and Zookeeper
function Start-Kafka {
    Write-Info "Checking Kafka and Zookeeper..."

    $kafkaRunning = Test-ContainerRunning "ecommerce-platform-kafka-1"
    $zookeeperRunning = Test-ContainerRunning "ecommerce-platform-zookeeper-1"

    if ($kafkaRunning -and $zookeeperRunning) {
        Write-Success "Kafka and Zookeeper are already running"
        return $true
    }

    Write-Info "Starting Kafka and Zookeeper with Docker Compose..."
    docker compose up -d 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Kafka and Zookeeper started successfully"
        Start-Sleep -Seconds 3
        return $true
    } else {
        Write-Err "Failed to start Kafka and Zookeeper"
        return $false
    }
}

# Start MongoDB
function Start-MongoDB {
    if (Test-ContainerRunning $MONGO_CONTAINER) {
        Write-Success "MongoDB ($MONGO_CONTAINER) is already running on port $MONGO_PORT"
        return $true
    }

    Write-Info "Starting MongoDB for $SERVICE_NAME..."
    docker run -d --name $MONGO_CONTAINER -p "${MONGO_PORT}:27017" $MONGO_IMAGE 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "MongoDB started on port $MONGO_PORT"
        return $true
    } else {
        Write-Err "Failed to start MongoDB"
        return $false
    }
}

# Stop MongoDB
function Stop-MongoDB {
    if (Test-ContainerRunning $MONGO_CONTAINER) {
        Write-Info "Stopping MongoDB ($MONGO_CONTAINER)..."
        docker stop $MONGO_CONTAINER 2>&1 | Out-Null
        docker rm $MONGO_CONTAINER 2>&1 | Out-Null
        Write-Success "MongoDB stopped and removed"
    } else {
        Write-Info "MongoDB ($MONGO_CONTAINER) is not running"
    }
}

# Show status
function Show-Status {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   $SERVICE_NAME - Status" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # MongoDB Status
    $mongoRunning = Test-ContainerRunning $MONGO_CONTAINER
    if ($mongoRunning) {
        Write-Success "MongoDB: Running (port $MONGO_PORT)"
    } else {
        Write-Warn "MongoDB: Not running"
    }

    # Kafka Status
    $kafkaRunning = Test-ContainerRunning "ecommerce-platform-kafka-1"
    if ($kafkaRunning) {
        Write-Success "Kafka: Running (port 9092)"
    } else {
        Write-Warn "Kafka: Not running"
    }

    # Zookeeper Status
    $zookeeperRunning = Test-ContainerRunning "ecommerce-platform-zookeeper-1"
    if ($zookeeperRunning) {
        Write-Success "Zookeeper: Running (port 2181)"
    } else {
        Write-Warn "Zookeeper: Not running"
    }

    # Application Status
    $portInUse = Get-NetTCPConnection -LocalPort $SERVICE_PORT -State Listen -ErrorAction SilentlyContinue
    if ($portInUse) {
        Write-Success "Application: Running (port $SERVICE_PORT)"
        Write-Info "Swagger UI: $SWAGGER_URL"
    } else {
        Write-Warn "Application: Not running"
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

# Start action
function Start-Service {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   Starting $SERVICE_NAME" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    # Check Docker
    if (-not (Test-DockerRunning)) {
        exit 1
    }

    # Start Kafka
    if (-not (Start-Kafka)) {
        exit 1
    }

    # Start MongoDB
    if (-not (Start-MongoDB)) {
        exit 1
    }

    Write-Host ""
    Write-Success "All infrastructure components are running!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. Build:   mvn clean install -DskipTests" -ForegroundColor Yellow
    Write-Host "  2. Run:     mvn spring-boot:run" -ForegroundColor Yellow
    Write-Host "  3. Test:    $SWAGGER_URL" -ForegroundColor Yellow
    Write-Host ""
}

# Stop action
function Stop-Service {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "   Stopping $SERVICE_NAME" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""

    Stop-MongoDB

    Write-Host ""
    Write-Warn "Kafka and Zookeeper are still running (shared across services)"
    Write-Info "To stop Kafka: docker compose down"
    Write-Host ""
}

# Main execution
if ($Action -eq "help" -or $Action -eq "h") {
    Show-Help
    exit 0
}

switch ($Action) {
    "start" {
        Start-Service
    }
    "stop" {
        Stop-Service
    }
    "status" {
        Show-Status
    }
    default {
        Write-Err "Invalid action: --$Action"
        Write-Host ""
        Show-Help
        exit 1
    }
}

