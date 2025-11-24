# Tools

Utility scripts for data management and testing.

## 📁 Available Tools

### seed-products.ps1

Product data seeding and management tool.

**Purpose:** Populate the database with realistic dummy product data for testing and development.

**Usage:**
```powershell
.\tools\seed-products.ps1 <seed|clear|reseed|help>
```

**Actions:**

| Action | Description |
|--------|-------------|
| `seed` | Add 50 dummy products to the database |
| `clear` | Delete all products from the database |
| `reseed` | Clear all products and add fresh dummy data |
| `help` | Display help message |

**Examples:**

```powershell
# Add 50 products
.\tools\seed-products.ps1 seed

# Delete all products
.\tools\seed-products.ps1 clear

# Clear and add fresh data
.\tools\seed-products.ps1 reseed
```

**Requirements:**
- Product Service must be running on port 7070
- Start with: `.\scripts\product-service.ps1 --start`
- Run with: `mvn spring-boot:run`

**Product Categories:**
- Electronics (Laptops, Smartphones, Tablets, etc.)
- Clothing (T-Shirts, Jeans, Jackets, etc.)
- Books (Programming, Novels, Cookbooks, etc.)
- Home & Garden (Coffee Makers, Vacuum Cleaners, etc.)
- Sports (Yoga Mats, Dumbbells, Tennis Rackets, etc.)
- Toys (Board Games, Puzzles, Action Figures, etc.)
- Food (Coffee Beans, Chocolates, Tea Sets, etc.)
- Beauty (Skincare, Perfumes, Hair Dryers, etc.)
- Automotive (Phone Holders, Dash Cameras, etc.)
- Music (Guitars, Microphones, Keyboards, etc.)

**Features:**
- Realistic product names with brands and adjectives
- Varied prices based on product category
- Randomized stock quantities
- Detailed product descriptions
- Progress indicators during seeding
- Error handling and retry logic

**Sample Output:**
```
[OK] Reseeding completed!
  - Deleted: 42 products
  - Added: 44 products
  - Failed: 6 products
```

**Note:** Failed products are typically due to duplicate names, which is expected and harmless.

