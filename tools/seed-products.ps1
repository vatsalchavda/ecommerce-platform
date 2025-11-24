# Product Data Seeding Script
# Usage: .\tools\seed-products.ps1 <--seed|--clear|--reseed|--help>
# Example: .\tools\seed-products.ps1 --seed

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Action = "--help"
)

# Normalize action (remove -- prefix if present, convert to lowercase)
$Action = $Action.ToLower().TrimStart('-')

# Configuration
$API_BASE_URL = "http://localhost:7070/api/products"
$SEED_COUNT = 50  # Number of products to seed

# Color output functions
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

# Product data templates
$categories = @("Electronics", "Clothing", "Books", "Home & Garden", "Sports", "Toys", "Food", "Beauty", "Automotive", "Music")

$productTemplates = @(
    # Electronics
    @{ name = "Laptop"; description = "High-performance laptop with latest processor"; category = "Electronics"; priceRange = @(800, 2500); stockRange = @(10, 50) },
    @{ name = "Smartphone"; description = "Latest smartphone with advanced camera"; category = "Electronics"; priceRange = @(400, 1200); stockRange = @(20, 100) },
    @{ name = "Tablet"; description = "Portable tablet for work and entertainment"; category = "Electronics"; priceRange = @(300, 900); stockRange = @(15, 60) },
    @{ name = "Headphones"; description = "Noise-cancelling wireless headphones"; category = "Electronics"; priceRange = @(50, 400); stockRange = @(30, 150) },
    @{ name = "Monitor"; description = "4K ultra HD monitor"; category = "Electronics"; priceRange = @(200, 800); stockRange = @(10, 40) },
    @{ name = "Keyboard"; description = "Mechanical gaming keyboard with RGB"; category = "Electronics"; priceRange = @(50, 200); stockRange = @(25, 100) },
    @{ name = "Mouse"; description = "Ergonomic wireless mouse"; category = "Electronics"; priceRange = @(20, 100); stockRange = @(50, 200) },
    @{ name = "Webcam"; description = "Full HD webcam for video calls"; category = "Electronics"; priceRange = @(40, 150); stockRange = @(20, 80) },

    # Clothing
    @{ name = "T-Shirt"; description = "Comfortable cotton t-shirt"; category = "Clothing"; priceRange = @(15, 50); stockRange = @(50, 200) },
    @{ name = "Jeans"; description = "Classic denim jeans"; category = "Clothing"; priceRange = @(40, 120); stockRange = @(30, 150) },
    @{ name = "Jacket"; description = "Stylish waterproof jacket"; category = "Clothing"; priceRange = @(60, 200); stockRange = @(20, 80) },
    @{ name = "Sneakers"; description = "Athletic running sneakers"; category = "Clothing"; priceRange = @(50, 150); stockRange = @(25, 100) },
    @{ name = "Dress"; description = "Elegant evening dress"; category = "Clothing"; priceRange = @(80, 300); stockRange = @(15, 60) },
    @{ name = "Hoodie"; description = "Warm fleece hoodie"; category = "Clothing"; priceRange = @(35, 90); stockRange = @(40, 120) },

    # Books
    @{ name = "Programming Book"; description = "Comprehensive guide to software development"; category = "Books"; priceRange = @(30, 80); stockRange = @(20, 100) },
    @{ name = "Novel"; description = "Bestselling fiction novel"; category = "Books"; priceRange = @(15, 35); stockRange = @(50, 200) },
    @{ name = "Cookbook"; description = "International cuisine recipes"; category = "Books"; priceRange = @(20, 50); stockRange = @(30, 120) },
    @{ name = "Biography"; description = "Inspiring life story"; category = "Books"; priceRange = @(18, 40); stockRange = @(25, 100) },

    # Home & Garden
    @{ name = "Coffee Maker"; description = "Programmable coffee maker"; category = "Home & Garden"; priceRange = @(50, 200); stockRange = @(15, 60) },
    @{ name = "Vacuum Cleaner"; description = "Powerful cordless vacuum"; category = "Home & Garden"; priceRange = @(150, 500); stockRange = @(10, 40) },
    @{ name = "Blender"; description = "High-speed blender for smoothies"; category = "Home & Garden"; priceRange = @(40, 150); stockRange = @(20, 80) },
    @{ name = "Plant Pot"; description = "Decorative ceramic plant pot"; category = "Home & Garden"; priceRange = @(10, 50); stockRange = @(40, 150) },
    @{ name = "Lamp"; description = "Modern LED desk lamp"; category = "Home & Garden"; priceRange = @(25, 100); stockRange = @(30, 120) },

    # Sports
    @{ name = "Yoga Mat"; description = "Non-slip exercise yoga mat"; category = "Sports"; priceRange = @(20, 60); stockRange = @(30, 150) },
    @{ name = "Dumbbell Set"; description = "Adjustable weight dumbbells"; category = "Sports"; priceRange = @(50, 200); stockRange = @(15, 60) },
    @{ name = "Tennis Racket"; description = "Professional tennis racket"; category = "Sports"; priceRange = @(80, 300); stockRange = @(10, 40) },
    @{ name = "Basketball"; description = "Official size basketball"; category = "Sports"; priceRange = @(20, 60); stockRange = @(25, 100) },
    @{ name = "Bicycle"; description = "Mountain bike with 21 gears"; category = "Sports"; priceRange = @(300, 1000); stockRange = @(5, 25) },

    # Toys
    @{ name = "Board Game"; description = "Family strategy board game"; category = "Toys"; priceRange = @(25, 80); stockRange = @(30, 120) },
    @{ name = "Puzzle"; description = "1000-piece jigsaw puzzle"; category = "Toys"; priceRange = @(15, 40); stockRange = @(40, 150) },
    @{ name = "Action Figure"; description = "Collectible action figure"; category = "Toys"; priceRange = @(20, 100); stockRange = @(50, 200) },
    @{ name = "Building Blocks"; description = "Creative building block set"; category = "Toys"; priceRange = @(30, 150); stockRange = @(20, 100) },

    # Food
    @{ name = "Coffee Beans"; description = "Premium arabica coffee beans"; category = "Food"; priceRange = @(15, 40); stockRange = @(50, 200) },
    @{ name = "Chocolate Box"; description = "Assorted luxury chocolates"; category = "Food"; priceRange = @(20, 60); stockRange = @(40, 150) },
    @{ name = "Tea Set"; description = "Variety pack of premium teas"; category = "Food"; priceRange = @(25, 70); stockRange = @(30, 120) },
    @{ name = "Olive Oil"; description = "Extra virgin olive oil"; category = "Food"; priceRange = @(18, 50); stockRange = @(35, 140) },

    # Beauty
    @{ name = "Skincare Set"; description = "Complete skincare routine kit"; category = "Beauty"; priceRange = @(40, 150); stockRange = @(20, 80) },
    @{ name = "Perfume"; description = "Luxury fragrance"; category = "Beauty"; priceRange = @(50, 200); stockRange = @(15, 60) },
    @{ name = "Hair Dryer"; description = "Professional ionic hair dryer"; category = "Beauty"; priceRange = @(40, 150); stockRange = @(20, 80) },
    @{ name = "Makeup Palette"; description = "Versatile eyeshadow palette"; category = "Beauty"; priceRange = @(30, 100); stockRange = @(25, 100) },

    # Automotive
    @{ name = "Car Phone Holder"; description = "Magnetic car phone mount"; category = "Automotive"; priceRange = @(15, 40); stockRange = @(50, 200) },
    @{ name = "Dash Camera"; description = "Full HD dash cam with GPS"; category = "Automotive"; priceRange = @(60, 200); stockRange = @(20, 80) },
    @{ name = "Car Vacuum"; description = "Portable car vacuum cleaner"; category = "Automotive"; priceRange = @(30, 80); stockRange = @(25, 100) },
    @{ name = "Floor Mats"; description = "All-weather car floor mats"; category = "Automotive"; priceRange = @(40, 100); stockRange = @(30, 120) },

    # Music
    @{ name = "Guitar"; description = "Acoustic guitar for beginners"; category = "Music"; priceRange = @(150, 600); stockRange = @(10, 40) },
    @{ name = "Microphone"; description = "USB condenser microphone"; category = "Music"; priceRange = @(60, 200); stockRange = @(20, 80) },
    @{ name = "Music Stand"; description = "Adjustable sheet music stand"; category = "Music"; priceRange = @(20, 60); stockRange = @(30, 100) },
    @{ name = "Piano Keyboard"; description = "61-key digital keyboard"; category = "Music"; priceRange = @(200, 800); stockRange = @(8, 30) }
)

$brands = @("Pro", "Elite", "Premium", "Standard", "Deluxe", "Ultra", "Max", "Plus", "Prime", "Essential")
$adjectives = @("Smart", "Advanced", "Professional", "Modern", "Classic", "Innovative", "Ergonomic", "Portable", "Wireless", "Compact")

# Function to generate random product
function Get-RandomProduct {
    $template = $productTemplates | Get-Random
    $brand = $brands | Get-Random
    $adjective = $adjectives | Get-Random

    # Generate random price within range
    $minPrice = [int]($template.priceRange[0] * 100)  # Convert to cents
    $maxPrice = [int]($template.priceRange[1] * 100)  # Convert to cents
    $priceInCents = Get-Random -Minimum $minPrice -Maximum $maxPrice
    $price = [math]::Round($priceInCents / 100.0, 2)

    # Generate random stock within range
    $minStock = $template.stockRange[0]
    $maxStock = $template.stockRange[1]
    $stock = Get-Random -Minimum $minStock -Maximum ($maxStock + 1)

    # Create product name with variation
    $productName = "$adjective $brand $($template.name)"

    return @{
        name = $productName
        description = $template.description
        price = $price
        category = $template.category
        stockQuantity = $stock
    }
}

# Function to check if API is accessible
function Test-ApiAvailable {
    try {
        $response = Invoke-RestMethod -Uri $API_BASE_URL -Method Get -TimeoutSec 5 -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Function to get all products
function Get-AllProducts {
    try {
        $response = Invoke-RestMethod -Uri $API_BASE_URL -Method Get -ErrorAction Stop
        return $response
    } catch {
        Write-Err "Failed to get products: $($_.Exception.Message)"
        return @()
    }
}

# Function to delete all products
function Clear-AllProducts {
    Write-Info "Fetching all products..."
    $products = Get-AllProducts

    if ($products.Count -eq 0) {
        Write-Info "No products found. Database is already empty."
        return 0
    }

    Write-Info "Found $($products.Count) products. Deleting..."

    $deletedCount = 0
    foreach ($product in $products) {
        try {
            Invoke-RestMethod -Uri "$API_BASE_URL/$($product.id)" -Method Delete -ErrorAction Stop | Out-Null
            $deletedCount++
            Write-Host "." -NoNewline -ForegroundColor Gray
        } catch {
            Write-Warn "Failed to delete product $($product.id): $($_.Exception.Message)"
        }
    }

    Write-Host ""
    return $deletedCount
}

# Function to seed products
function Add-SeedProducts {
    param([int]$Count)

    Write-Info "Seeding $Count products..."

    $successCount = 0
    $failCount = 0

    for ($i = 1; $i -le $Count; $i++) {
        $product = Get-RandomProduct
        $jsonBody = $product | ConvertTo-Json

        try {
            $response = Invoke-RestMethod -Uri $API_BASE_URL `
                -Method Post `
                -Body $jsonBody `
                -ContentType "application/json" `
                -ErrorAction Stop

            $successCount++
            Write-Host "." -NoNewline -ForegroundColor Green

            # Progress indicator every 10 products
            if ($i % 10 -eq 0) {
                Write-Host " [$i/$Count]" -ForegroundColor Cyan
            }
        } catch {
            $failCount++
            Write-Host "x" -NoNewline -ForegroundColor Red
        }

        # Small delay to avoid overwhelming the API
        Start-Sleep -Milliseconds 100
    }

    Write-Host ""
    return @{ success = $successCount; failed = $failCount }
}

# Help function
function Show-Help {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Product Data Seeding Tool" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\tools\seed-products.ps1 <--seed|--clear|--reseed|--help>" -ForegroundColor White
    Write-Host ""
    Write-Host "ACTIONS:" -ForegroundColor Yellow
    Write-Host "  --seed    - Add $SEED_COUNT dummy products to the database" -ForegroundColor White
    Write-Host "  --clear   - Delete all products from the database" -ForegroundColor White
    Write-Host "  --reseed  - Clear all products and add fresh dummy data" -ForegroundColor White
    Write-Host "  --help    - Display this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\tools\seed-products.ps1 --seed      # Add 50 products" -ForegroundColor Gray
    Write-Host "  .\tools\seed-products.ps1 --clear     # Delete all products" -ForegroundColor Gray
    Write-Host "  .\tools\seed-products.ps1 --reseed    # Clear + seed fresh data" -ForegroundColor Gray
    Write-Host ""
    Write-Host "REQUIREMENTS:" -ForegroundColor Yellow
    Write-Host "  - Product Service must be running on port 7070" -ForegroundColor White
    Write-Host "  - Start with: .\scripts\product-service.ps1 --start" -ForegroundColor Gray
    Write-Host "  - Run with: mvn spring-boot:run" -ForegroundColor Gray
    Write-Host ""
    Write-Host "PRODUCT CATEGORIES:" -ForegroundColor Yellow
    foreach ($cat in $categories) {
        Write-Host "  - $cat" -ForegroundColor White
    }
    Write-Host ""
}

# Seed action
function Invoke-Seed {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   Seeding Product Data" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    # Check if API is available
    Write-Info "Checking if Product Service is running..."
    if (-not (Test-ApiAvailable)) {
        Write-Err "Product Service is not accessible at $API_BASE_URL"
        Write-Host ""
        Write-Warn "Please ensure:"
        Write-Host "  1. Product Service is started: .\scripts\product-service.ps1 --start" -ForegroundColor Yellow
        Write-Host "  2. Application is running: mvn spring-boot:run" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
    Write-Success "Product Service is accessible"

    # Seed products
    $result = Add-SeedProducts -Count $SEED_COUNT

    Write-Host ""
    Write-Success "Seeding completed!"
    Write-Host "  - Successfully added: $($result.success) products" -ForegroundColor Green
    if ($result.failed -gt 0) {
        Write-Host "  - Failed: $($result.failed) products" -ForegroundColor Red
    }
    Write-Host ""
}

# Clear action
function Invoke-Clear {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "   Clearing Product Data" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""

    # Check if API is available
    Write-Info "Checking if Product Service is running..."
    if (-not (Test-ApiAvailable)) {
        Write-Err "Product Service is not accessible at $API_BASE_URL"
        Write-Host ""
        Write-Warn "Please ensure Product Service is running"
        Write-Host ""
        exit 1
    }
    Write-Success "Product Service is accessible"

    # Clear products
    $deletedCount = Clear-AllProducts

    Write-Host ""
    Write-Success "Cleared $deletedCount products from the database"
    Write-Host ""
}

# Reseed action
function Invoke-Reseed {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "   Reseeding Product Data" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""

    # Check if API is available
    Write-Info "Checking if Product Service is running..."
    if (-not (Test-ApiAvailable)) {
        Write-Err "Product Service is not accessible at $API_BASE_URL"
        Write-Host ""
        Write-Warn "Please ensure Product Service is running"
        Write-Host ""
        exit 1
    }
    Write-Success "Product Service is accessible"
    Write-Host ""

    # Clear existing products
    Write-Info "Step 1: Clearing existing products..."
    $deletedCount = Clear-AllProducts
    Write-Success "Cleared $deletedCount products"
    Write-Host ""

    # Seed new products
    Write-Info "Step 2: Seeding fresh product data..."
    $result = Add-SeedProducts -Count $SEED_COUNT

    Write-Host ""
    Write-Success "Reseeding completed!"
    Write-Host "  - Deleted: $deletedCount products" -ForegroundColor Yellow
    Write-Host "  - Added: $($result.success) products" -ForegroundColor Green
    if ($result.failed -gt 0) {
        Write-Host "  - Failed: $($result.failed) products" -ForegroundColor Red
    }
    Write-Host ""
}

# Main execution
if ($Action -eq "help" -or $Action -eq "h") {
    Show-Help
    exit 0
}

switch ($Action) {
    "seed" {
        Invoke-Seed
    }
    "clear" {
        Invoke-Clear
    }
    "reseed" {
        Invoke-Reseed
    }
    default {
        Write-Err "Invalid action: --$Action"
        Write-Host ""
        Show-Help
        exit 1
    }
}

