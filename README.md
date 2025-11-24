# E-Commerce Platform - Microservices Architecture

A modern, production-ready e-commerce platform built with **Spring Boot**, **MongoDB**, **Kafka**, **React**, **Docker**, and **Kubernetes**.

## 🎯 Project Overview

A scalable microservices-based e-commerce platform demonstrating modern cloud-native architecture, distributed systems, and event-driven design patterns.

## 🏗️ Architecture

### Microservices
- **Product Service** ✅ - Product catalog management (CRUD operations)
- **Order Service** ⏳ - Order processing and management
- **User Service** ⏳ - Authentication and user management
- **API Gateway** ⏳ - Centralized routing and authentication

### Event-Driven Communication
- **Apache Kafka** - Asynchronous messaging between services
- **Event Sourcing** - Track all state changes as events

## 🛠️ Tech Stack

### Backend
- **Spring Boot 3.2.0** - Java 17
- **Spring Data MongoDB** - NoSQL database
- **Spring Validation** - Request validation
- **Apache Kafka** - Event streaming
- **Swagger/OpenAPI** - API documentation
- **Lombok** - Reduce boilerplate code
- **SLF4J** - Logging

### Frontend (Coming Soon)
- **React 18** - UI framework
- **React Context API** - State management
- **Bootstrap** - Styling
- **Axios** - HTTP client

### DevOps & Infrastructure
- **Docker** - Containerization
- **Docker Compose** - Local development
- **Kubernetes (Minikube)** - Container orchestration
- **MongoDB** - Document database
- **Maven** - Build tool

### Observability (Planned)
- **Prometheus** - Metrics collection
- **Grafana** - Monitoring dashboards
- **ELK Stack** - Centralized logging
- **Jaeger** - Distributed tracing

## 📦 Product Service (Current Status)

### Features Implemented ✅
- ✅ **CRUD Operations** - Create, Read, Update, Delete products
- ✅ **Request Validation** - Bean Validation with custom constraints
- ✅ **Exception Handling** - Global exception handler with standardized error responses
- ✅ **MongoDB Integration** - Document-based storage
- ✅ **API Documentation** - Swagger UI auto-generated
- ✅ **Logging** - SLF4J with structured logging
- ✅ **Docker Support** - MongoDB containerized

### API Endpoints

| Method | Endpoint | Description | Status Code |
|--------|----------|-------------|-------------|
| GET | `/api/products` | Get all products | 200 OK |
| GET | `/api/products/{id}` | Get product by ID | 200 OK / 404 Not Found |
| GET | `/api/products/category/{category}` | Get products by category | 200 OK |
| POST | `/api/products` | Create new product | 201 Created / 400 Bad Request |
| PUT | `/api/products/{id}` | Update product | 200 OK / 404 Not Found |
| DELETE | `/api/products/{id}` | Delete product | 204 No Content / 404 Not Found |

### Validation Rules

- **Name**: 3-100 characters, required
- **Description**: 10-500 characters, required
- **Price**: Greater than 0, required
- **Category**: Alphanumeric + spaces only, required
- **Stock Quantity**: Non-negative, required

## 🚀 Getting Started

### Prerequisites

- **Java 17** or higher
- **Maven 3.8+**
- **Docker Desktop**
- **Git**

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:vatsalchavda/ecommerce-platform.git
   cd ecommerce-platform
   ```

2. **Start Infrastructure**
   ```powershell
   # Start Product Service infrastructure (MongoDB, Kafka, Zookeeper)
   .\scripts\product-service.ps1 --start
   ```

3. **Build and Run**
   ```bash
   mvn clean install
   mvn spring-boot:run
   ```

4. **Access Swagger UI**
   ```
   http://localhost:7070/swagger-ui/index.html
   ```

5. **Check Service Status**
   ```powershell
   .\scripts\product-service.ps1 --status
   ```

6. **Stop Service**
   ```powershell
   # Stop Product Service (keeps Kafka running)
   .\scripts\product-service.ps1 --stop
   
   # Stop all services including Kafka
   .\scripts\manage-all.ps1 --stop
   ```

### Service Management Scripts

```powershell
# Product Service commands
.\scripts\product-service.ps1 --start    # Start infrastructure
.\scripts\product-service.ps1 --stop     # Stop infrastructure
.\scripts\product-service.ps1 --status   # Check status
.\scripts\product-service.ps1 --help     # Show help

# Manage all services
.\scripts\manage-all.ps1 --start         # Start all services
.\scripts\manage-all.ps1 --stop          # Stop all services
.\scripts\manage-all.ps1 --status        # Check all services
.\scripts\manage-all.ps1 --help          # Show help
```

## 🛠️ Development Environment

### Starting the Service

```powershell
# 1. Start infrastructure (MongoDB, Kafka, Zookeeper)
.\scripts\product-service.ps1 --start

# 2. Build and run the application
mvn clean install -DskipTests
mvn spring-boot:run

# 3. Verify everything is running
.\scripts\product-service.ps1 --status
```

### Stopping the Service

```powershell
# Stop Product Service (keeps Kafka running for other services)
.\scripts\product-service.ps1 --stop

# Stop all services including Kafka
.\scripts\manage-all.ps1 --stop
```

### Checking Status

```powershell
# Check Product Service
.\scripts\product-service.ps1 --status

# Check all services
.\scripts\manage-all.ps1 --status
```

### Manual Setup (Alternative)

```bash
# Start Kafka and Zookeeper
docker compose up -d

# Start MongoDB
docker run -d --name product-mongodb -p 27018:27017 mongo:7.0

# Build and run
mvn clean install
mvn spring-boot:run
```


### Configuration

Application runs on **port 7070** by default.

MongoDB connection: `localhost:27018`

Configuration file: `src/main/resources/application.yml`

## 📁 Project Structure

```
ecommerce-platform/
├── src/main/java/com/ecommerce/
│   ├── ProductServiceApplication.java          # Main application class
│   └── product/
│       ├── controller/
│       │   └── ProductController.java          # REST endpoints
│       ├── service/
│       │   └── ProductService.java             # Business logic
│       ├── repository/
│       │   └── ProductRepository.java          # Database access
│       ├── model/
│       │   └── Product.java                    # MongoDB entity
│       ├── event/
│       │   ├── ProductEvent.java               # Event DTO
│       │   └── EventType.java                  # Event types
│       ├── messaging/
│       │   ├── KafkaProductProducer.java       # Kafka producer
│       │   └── KafkaProductConsumer.java       # Kafka consumer
│       ├── exception/
│       │   ├── ProductNotFoundException.java   # Custom exception
│       │   ├── ErrorResponse.java              # Error DTO
│       │   └── GlobalExceptionHandler.java     # Exception handling
│       └── dto/                                # Data Transfer Objects
├── src/main/resources/
│   └── application.yml                         # Configuration
├── scripts/
│   ├── product-service.ps1                     # Service management
│   ├── manage-all.ps1                          # All services management
│   └── test-kafka.ps1                          # Kafka testing
├── tools/
│   └── seed-products.ps1                       # Data seeding utility
├── docker-compose.yml                          # Kafka & Zookeeper
├── pom.xml                                     # Maven dependencies
└── README.md
```

## 🧪 Testing & Data Management

### Seed Test Data

Populate the database with realistic dummy products:

```powershell
# Add 50 products
.\tools\seed-products.ps1 seed

# Clear all products
.\tools\seed-products.ps1 clear

# Clear and reseed
.\tools\seed-products.ps1 reseed
```

See `tools/README.md` for more details.

### Manual Testing with Swagger UI

Access Swagger UI at: `http://localhost:7070/swagger-ui.html`

### Create a Product
```json
POST /api/products
{
  "name": "Gaming Laptop",
  "description": "High-performance laptop with RTX 4080 GPU",
  "price": 1999.99,
  "category": "Electronics",
  "stockQuantity": 15
}
```

### Test Validation Error
```json
POST /api/products
{
  "name": "AB",
  "price": -10
}

Response: 400 Bad Request
{
  "timestamp": "2025-11-21T...",
  "status": 400,
  "error": "Validation Failed",
  "errors": [
    "name: Product name must be between 3 and 100 characters",
    "price: Price must be greater than 0",
    "description: Product description is required"
  ]
}
```

## 📨 Kafka & Zookeeper - Event-Driven Messaging

### What is Apache Kafka?

**Apache Kafka** is a distributed event streaming platform used for building real-time data pipelines and streaming applications. In microservices architecture, Kafka enables **asynchronous, decoupled communication** between services.

### Why Kafka for E-Commerce?

In our platform, Kafka handles:
- **Product Events** - Notify other services when products are created/updated/deleted
- **Order Events** - Real-time order processing and status updates
- **Inventory Events** - Stock level synchronization across services
- **Decoupling** - Services don't need to know about each other directly
- **Scalability** - Handle thousands of events per second
- **Reliability** - Events are persisted and can be replayed

### What is Zookeeper?

**Apache Zookeeper** is a distributed coordination service that Kafka uses for:

1. **Broker Management** - Tracks which Kafka brokers (servers) are alive
2. **Leader Election** - Coordinates which broker leads each partition
3. **Topic Metadata** - Stores configuration about topics and partitions
4. **Cluster Coordination** - Manages distributed consensus

**Note:** Kafka 3.x+ introduced KRaft mode (removes Zookeeper dependency), but Zookeeper is still industry standard and widely used in production.

### Architecture in This Project

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  Product Service│─────────▶│   Kafka Broker  │◀────────│  Order Service  │
│   (Producer)    │  Events  │                 │  Events │   (Consumer)    │
└─────────────────┘         │   Port: 9092    │         └─────────────────┘
                             │                 │
                             │  Managed by:    │
                             │   Zookeeper     │
                             │   Port: 2181    │
                             └─────────────────┘
```

### Event Flow Example

1. **Product Service** creates a new product → publishes `ProductCreatedEvent` to Kafka
2. **Kafka** stores the event in the `products` topic
3. **Order Service** consumes the event → updates its product catalog cache
4. **Inventory Service** consumes the event → initializes stock tracking

### Running Kafka & Zookeeper

**Start with Docker Compose:**
```bash
docker compose up -d
```

This starts:
- **Zookeeper** on `localhost:2181`
- **Kafka** on `localhost:9092`

**Check running containers:**
```bash
docker ps
```

**View Kafka logs:**
```bash
docker logs ecommerce-platform-kafka-1
```

**Stop services:**
```bash
docker compose down
```

### Docker Compose Configuration

Our `docker-compose.yml` uses **Confluent Platform images** (industry standard):

- **Zookeeper**: `confluentinc/cp-zookeeper:7.5.0`
  - Manages Kafka cluster metadata
  - Port: 2181
  
- **Kafka**: `confluentinc/cp-kafka:7.5.0`
  - Message broker
  - Port: 9092
  - Replication factor: 1 (single broker for local dev)

### Kafka Topics in This Project

| Topic Name | Purpose | Producer | Consumer |
|------------|---------|----------|----------|
| `products` | Product lifecycle events | Product Service | Order, Inventory Services |
| `orders` | Order processing events | Order Service | Inventory, Notification Services |
| `inventory` | Stock level updates | Inventory Service | Product Service |

### Key Kafka Concepts

- **Topic** - A category/stream of events (e.g., "products")
- **Producer** - Service that publishes events to a topic
- **Consumer** - Service that subscribes to and processes events
- **Partition** - Topics are split into partitions for parallelism
- **Offset** - Unique ID for each message in a partition
- **Consumer Group** - Multiple consumers share workload

### Spring Boot Kafka Integration

We use **Spring Kafka** to:
- Serialize/deserialize events as JSON
- Auto-configure producers and consumers
- Handle retries and error handling
- Provide simple annotations (`@KafkaListener`)

**Configuration** in `application.yml`:
```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: ecommerce-group
    producer:
      key-serializer: StringSerializer
      value-serializer: JsonSerializer
```

## 🔧 Technical Highlights

### Architecture & Design
- **Microservices Architecture** - Independently deployable services
- **Event-Driven Design** - Asynchronous communication via Kafka
- **Repository Pattern** - Clean data access abstraction
- **Layered Architecture** - Clear separation of concerns (Controller → Service → Repository)

### Key Technologies
- **Spring Boot 3.2.0** - Modern Java framework with dependency injection
- **Spring Data MongoDB** - Reactive repository abstraction
- **Bean Validation** - Request validation with Jakarta Validation API
- **Global Exception Handling** - Centralized error management with @RestControllerAdvice
- **OpenAPI/Swagger** - Interactive API documentation

## 📋 Roadmap

### Phase 1: Product Service ✅ **COMPLETED**
- [x] Spring Boot setup
- [x] MongoDB integration
- [x] CRUD operations
- [x] Request validation
- [x] Exception handling
- [x] API documentation

### Phase 2: Event-Driven Architecture ✅ **COMPLETED**
- [x] Kafka setup (Docker Compose)
- [x] Event publishing (ProductCreated, ProductUpdated, ProductDeleted)
- [x] Event consumers
- [x] Kafka producer/consumer configuration
- [x] Event-driven service integration

### Phase 3: Order Service ⏳ **NEXT**
- [ ] Order management microservice
- [ ] Kafka integration
- [ ] Product event consumption
- [ ] Order status management

### Phase 4: Additional Services ⏳
- [ ] User/Auth Service (JWT)
- [ ] API Gateway (Spring Cloud Gateway)
- [ ] Service-to-service communication

### Phase 5: Frontend ⏳
- [ ] React application
- [ ] Product catalog UI
- [ ] Shopping cart
- [ ] Checkout flow

### Phase 6: Containerization ⏳
- [ ] Dockerfile for all services
- [ ] Docker Compose for local deployment
- [ ] Multi-stage builds

### Phase 7: Kubernetes ⏳
- [ ] Minikube setup
- [ ] Kubernetes manifests
- [ ] ConfigMaps & Secrets
- [ ] Service deployment

### Phase 8: Observability ⏳
- [ ] Prometheus metrics
- [ ] Grafana dashboards
- [ ] ELK Stack logging
- [ ] Jaeger tracing

## 🤝 Contributing

Want to add a new microservice or enhance existing ones? Check out our [Contributing Guide](CONTRIBUTING.md) for:

- Step-by-step guide to adding new microservices
- Code standards and architectural patterns
- Kafka event integration guidelines
- Testing best practices
- Commit conventions

The guide walks through the entire process using the existing Product Service as a reference.

## 📝 License

This project is for educational purposes.

## 👤 Author

**Vatsal Chavda**

A scalable, production-ready e-commerce platform showcasing modern microservices architecture.

---

**Status:** Product Service completed. Kafka integration in progress. 🚀

