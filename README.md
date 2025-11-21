# E-Commerce Platform - Microservices Architecture

A modern, production-ready e-commerce platform built with **Spring Boot**, **MongoDB**, **Kafka**, **React**, **Docker**, and **Kubernetes**.

## 🎯 Project Goals

- Build a scalable microservices-based e-commerce platform
- Demonstrate industry-standard development practices
- Learn modern cloud-native technologies
- Prepare for Senior Software Developer technical interviews
- Understand distributed systems and event-driven architecture

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
   git clone https://github.com/YOUR_USERNAME/ecommerce-platform.git
   cd ecommerce-platform
   ```

2. **Start MongoDB**
   ```bash
   docker run -d --name product-mongodb -p 27018:27017 mongo:7.0
   ```

3. **Build the project**
   ```bash
   mvn clean install
   ```

4. **Run the application**
   ```bash
   mvn spring-boot:run
   ```

5. **Access Swagger UI**
   ```
   http://localhost:7070/swagger-ui/index.html
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
│       ├── exception/
│       │   ├── ProductNotFoundException.java   # Custom exception
│       │   ├── ErrorResponse.java              # Error DTO
│       │   └── GlobalExceptionHandler.java     # Exception handling
│       └── dto/                                # Data Transfer Objects
├── src/main/resources/
│   └── application.yml                         # Configuration
├── pom.xml                                     # Maven dependencies
└── README.md
```

## 🧪 Testing with Swagger UI

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

## 🎓 Key Learnings & Concepts

### Design Patterns
- **Repository Pattern** - Data access abstraction
- **Service Layer Pattern** - Business logic separation
- **DTO Pattern** - Data transfer objects
- **Exception Handling Pattern** - Global error handling

### Spring Boot Features
- **Dependency Injection** - Constructor injection with Lombok
- **Bean Validation** - Jakarta Validation API
- **Spring Data MongoDB** - Repository abstraction
- **RestControllerAdvice** - Global exception handling
- **Swagger Integration** - Auto-generated API docs

### Best Practices
- ✅ Clean code architecture (Controller → Service → Repository)
- ✅ Proper HTTP status codes
- ✅ Input validation at multiple layers
- ✅ Standardized error responses
- ✅ Structured logging
- ✅ Separation of concerns

## 📋 Roadmap

### Phase 1: Product Service ✅ **COMPLETED**
- [x] Spring Boot setup
- [x] MongoDB integration
- [x] CRUD operations
- [x] Request validation
- [x] Exception handling
- [x] API documentation

### Phase 2: Event-Driven Architecture ⏳ **IN PROGRESS**
- [ ] Kafka setup (Docker)
- [ ] Event publishing (ProductCreated, ProductUpdated, ProductDeleted)
- [ ] Event consumers
- [ ] Dead letter queue handling

### Phase 3: Order Service ⏳
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

This is a learning project. Feel free to fork and experiment!

## 📝 License

This project is for educational purposes.

## 👤 Author

Built as a learning project to demonstrate modern microservices architecture and prepare for technical interviews.

---

**Current Status:** Product Service is production-ready with validation and exception handling. Moving to Kafka integration next! 🚀

