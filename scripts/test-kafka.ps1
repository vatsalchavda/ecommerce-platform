# Test Kafka Integration

# This script tests the complete Kafka integration by creating a product
# and verifying that events are published and consumed.

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Testing Kafka Integration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test data
$productData = @{
    name = "Gaming Laptop"
    description = "High-performance gaming laptop with RTX 4080 GPU"
    price = 1999.99
    category = "Electronics"
    stockQuantity = 25
} | ConvertTo-Json

Write-Host "[INFO] Creating test product..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Product Data:" -ForegroundColor Yellow
Write-Host $productData -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:7070/api/products" `
        -Method Post `
        -Body $productData `
        -ContentType "application/json"

    Write-Host "[OK] Product created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Yellow
    Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor Gray
    Write-Host ""
    Write-Host "[INFO] Check your Spring Boot console logs for:" -ForegroundColor Cyan
    Write-Host "  1. 'Publishing product event: CREATED for product ID: <id>'" -ForegroundColor White
    Write-Host "  2. 'Product event published successfully'" -ForegroundColor White
    Write-Host "  3. 'Received product event: CREATED for product: Gaming Laptop'" -ForegroundColor White
    Write-Host ""
    Write-Host "[OK] If you see all three messages, Kafka integration is working!" -ForegroundColor Green

} catch {
    Write-Host "[ERROR] Failed to create product" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Application is running (mvn spring-boot:run)" -ForegroundColor White
    Write-Host "  2. Accessible at http://localhost:7070" -ForegroundColor White
    Write-Host "  3. MongoDB and Kafka are running" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

