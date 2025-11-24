# Contributing Guide

Welcome to the E-Commerce Platform project! This guide will help you add new microservices to the existing framework.

## Prerequisites

Before adding a new service, ensure you have:
- Java 17+ installed
- Maven 3.8+
- Docker Desktop running
- Existing Product Service working (validates your setup)

## Adding a New Microservice

This guide walks through adding a new service (e.g., Order Service) to the platform. We'll follow the same patterns established in the Product Service.

### Step 1: Create Package Structure

Create your service packages under `src/main/java/com/ecommerce/`:

```
src/main/java/com/ecommerce/
└── order/                          # Your service name
    ├── controller/                 # REST endpoints
    ├── service/                    # Business logic
    ├── repository/                 # Database layer
    ├── model/                      # Domain entities
    ├── event/                      # Event DTOs
    ├── messaging/                  # Kafka producer/consumer
    ├── exception/                  # Custom exceptions
    └── dto/                        # Data transfer objects (optional)
```

### Step 2: Define Domain Model

Create your entity in the `model` package:

```java
@Document(collection = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    @Id
    private String id;
    
    // Business fields
    private String customerId;
    private List<OrderItem> items;
    private BigDecimal totalAmount;
    private OrderStatus status;
    
    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

**Pattern to follow:**
- Use `@Document` for MongoDB collections
- Use `@Id` for primary key
- Include `createdAt` and `updatedAt` timestamps
- Use Lombok (`@Data`, `@NoArgsConstructor`, `@AllArgsConstructor`) to reduce boilerplate

### Step 3: Create Repository

Add repository interface in the `repository` package:

```java
public interface OrderRepository extends MongoRepository<Order, String> {
    List<Order> findByCustomerId(String customerId);
    List<Order> findByStatus(OrderStatus status);
}
```

**Pattern to follow:**
- Extend `MongoRepository<Entity, ID>`
- Add custom query methods using Spring Data naming conventions
- Keep repository thin - complex queries can go in the service layer

### Step 4: Implement Service Layer

Create service class in the `service` package:

```java
@Service
@Slf4j
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;
    private final KafkaOrderProducer kafkaProducer;
    
    public Order createOrder(Order order) {
        log.info("Creating new order for customer: {}", order.getCustomerId());
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());
        order.setStatus(OrderStatus.PENDING);
        
        Order savedOrder = orderRepository.save(order);
        
        // Publish event
        OrderEvent event = new OrderEvent(
            savedOrder.getId(),
            savedOrder.getCustomerId(),
            savedOrder.getTotalAmount(),
            EventType.CREATED
        );
        kafkaProducer.sendOrderEvent(event);
        
        log.info("Order created successfully: {}", savedOrder.getId());
        return savedOrder;
    }
    
    // Additional CRUD methods...
}
```

**Pattern to follow:**
- Use `@Service` annotation
- Use `@Slf4j` for logging
- Use `@RequiredArgsConstructor` for constructor injection
- Set timestamps in service layer, not controller
- Publish Kafka events after database operations
- Log key operations (info level for business events, debug for details)

### Step 5: Build REST Controller

Create controller in the `controller` package:

```java
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
@Slf4j
public class OrderController {
    private final OrderService orderService;
    
    @PostMapping
    public ResponseEntity<Order> createOrder(@Valid @RequestBody Order order) {
        Order created = orderService.createOrder(order);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(@PathVariable String id) {
        Order order = orderService.getOrderById(id);
        return ResponseEntity.ok(order);
    }
    
    // Additional endpoints...
}
```

**Pattern to follow:**
- Use `@RestController` and `@RequestMapping`
- Use `@Valid` for request validation
- Return `ResponseEntity` with appropriate HTTP status codes
- Keep controllers thin - delegate to service layer
- Use RESTful conventions (GET, POST, PUT, DELETE)

### Step 6: Add Validation

Add validation annotations to your model:

```java
@NotBlank(message = "Customer ID is required")
private String customerId;

@NotNull(message = "Order items cannot be null")
@Size(min = 1, message = "Order must have at least one item")
private List<OrderItem> items;

@NotNull(message = "Total amount is required")
@DecimalMin(value = "0.01", message = "Total amount must be greater than 0")
private BigDecimal totalAmount;
```

**Pattern to follow:**
- Use Jakarta Validation annotations (`@NotNull`, `@NotBlank`, `@Size`, etc.)
- Provide clear, user-friendly error messages
- Validate at the DTO/Model level, not in controllers

### Step 7: Implement Exception Handling

Create custom exception:

```java
public class OrderNotFoundException extends RuntimeException {
    public OrderNotFoundException(String orderId) {
        super("Order not found with id: " + orderId);
    }
}
```

Add to global exception handler (if not already present):

```java
@ExceptionHandler(OrderNotFoundException.class)
public ResponseEntity<ErrorResponse> handleOrderNotFound(OrderNotFoundException ex) {
    ErrorResponse error = new ErrorResponse(
        LocalDateTime.now(),
        HttpStatus.NOT_FOUND.value(),
        "Order Not Found",
        ex.getMessage()
    );
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
}
```

**Pattern to follow:**
- Extend `RuntimeException` for custom exceptions
- Use meaningful exception names (e.g., `OrderNotFoundException`)
- Add handlers to existing `GlobalExceptionHandler`
- Return standardized `ErrorResponse` objects

### Step 8: Add Kafka Integration

#### Create Event DTO

In the `event` package:

```java
public record OrderEvent(
    String id,
    String customerId,
    BigDecimal totalAmount,
    EventType eventType
) {}
```

#### Create Kafka Producer

In the `messaging` package:

```java
@Service
@Slf4j
@RequiredArgsConstructor
public class KafkaOrderProducer {
    private static final String TOPIC = "order-events";
    private final KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public void sendOrderEvent(OrderEvent event) {
        log.info("Publishing order event: {} for order ID: {}", event.eventType(), event.id());
        
        kafkaTemplate.send(TOPIC, event.id(), event)
            .whenComplete((result, ex) -> {
                if (ex == null) {
                    log.info("Order event published successfully: {}", event.id());
                } else {
                    log.error("Failed to publish order event: {}", event.id(), ex);
                }
            });
    }
}
```

#### Create Kafka Consumer (if needed)

```java
@Component
@Slf4j
public class KafkaProductConsumer {
    
    @KafkaListener(topics = "product-events", groupId = "order-service-group")
    public void consumeProductEvent(ProductEvent event) {
        log.info("Received product event: {} for product: {}", 
            event.eventType(), event.name());
        
        // Handle event (e.g., update local product cache)
    }
}
```

**Pattern to follow:**
- Use Java records for event DTOs (immutable)
- One topic per entity type (e.g., `order-events`, `product-events`)
- Use entity ID as Kafka message key
- Async publishing with `whenComplete` callback
- Log both success and failure cases
- Use `@KafkaListener` for consumers with appropriate `groupId`

### Step 9: Configure Application Properties

Update `application.yml`:

```yaml
server:
  port: 8080  # Choose a different port for each service

spring:
  application:
    name: order-service
  data:
    mongodb:
      host: localhost
      port: 27019  # Different port per service
      database: order-db
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
      properties:
        spring.json.add.type.headers: false
    consumer:
      group-id: order-service-group
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.trusted.packages: '*'
      auto-offset-reset: earliest
```

**Important:**
- Each service gets a unique port (Product: 7070, Order: 8080, User: 8081, etc.)
- Each service gets its own MongoDB database and port
- All services share the same Kafka instance
- Update `group-id` to match your service name

### Step 10: Add Maven Dependencies (if new ones needed)

If you need additional dependencies, add to `pom.xml`:

```xml
<dependency>
    <groupId>org.example</groupId>
    <artifactId>new-dependency</artifactId>
    <version>1.0.0</version>
</dependency>
```

Existing dependencies in the project:
- Spring Boot Web
- Spring Data MongoDB
- Spring Kafka
- Spring Validation
- Lombok
- Swagger/OpenAPI

### Step 11: Create Service Management Script

Copy and modify the Product Service script:

```powershell
# Copy the template
Copy-Item scripts\product-service.ps1 scripts\order-service.ps1

# Edit the configuration section
$SERVICE_NAME = "Order Service"
$SERVICE_PORT = 8080
$MONGO_CONTAINER = "order-mongodb"
$MONGO_PORT = 27019
$MONGO_IMAGE = "mongo:7.0"
```

### Step 12: Update Manage-All Script

Add your service to `scripts/manage-all.ps1`:

```powershell
$SERVICES = @(
    @{
        name = "Product Service"
        script = "product-service.ps1"
        port = 7070
        enabled = $true
    },
    @{
        name = "Order Service"
        script = "order-service.ps1"
        port = 8080
        enabled = $true
    }
)
```

### Step 13: Update Docker Compose (if needed)

If your service needs additional infrastructure, update `docker-compose.yml`.

Kafka and Zookeeper are already configured and shared across all services.

### Step 14: Test Your Service

```powershell
# Start infrastructure
.\scripts\order-service.ps1 --start

# Build and run
mvn clean install -DskipTests
mvn spring-boot:run

# Check status
.\scripts\order-service.ps1 --status

# Test with Swagger
http://localhost:8080/swagger-ui.html
```

### Step 15: Update Documentation

1. Update main `README.md`:
   - Add your service to the Architecture section
   - Update the roadmap
   - Add API endpoints table

2. Create service-specific documentation if complex

## Code Standards

### Naming Conventions
- **Packages**: lowercase (e.g., `order`, `product`)
- **Classes**: PascalCase (e.g., `OrderService`, `ProductController`)
- **Methods**: camelCase (e.g., `createOrder`, `findById`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `TOPIC`, `MAX_RETRIES`)

### Layered Architecture
Always maintain clear separation:
```
Controller → Service → Repository → Database
     ↓          ↓
  Validation  Kafka Events
```

- **Controllers**: Handle HTTP, validate input, return responses
- **Services**: Business logic, transactions, event publishing
- **Repositories**: Database access only
- **Messaging**: Kafka producers/consumers

### Logging Best Practices
```java
log.info("Business event: Order created for customer {}", customerId);
log.debug("Technical detail: Processing {} items", items.size());
log.error("Error occurred while processing order {}", orderId, exception);
```

- Use `info` for business events
- Use `debug` for technical details
- Use `error` for exceptions (include stack trace)
- Use placeholders `{}` instead of string concatenation

### Error Handling
- Use custom exceptions for domain errors
- Use global exception handler for consistency
- Return standardized `ErrorResponse` objects
- Include timestamps and meaningful messages

## Kafka Event Patterns

### When to Publish Events
- After successful CREATE operations → `EventType.CREATED`
- After successful UPDATE operations → `EventType.UPDATED`
- Before DELETE operations → `EventType.DELETED` (so event contains full data)

### Topic Naming
- Use entity name + "-events" (e.g., `order-events`, `product-events`)
- One topic per aggregate root
- Events are immutable once published

### Consumer Groups
- Use service name as group ID (e.g., `order-service-group`)
- One group per service ensures all instances share the workload
- Different services use different groups to get all events

## Testing Guidelines

### What to Test
1. **Repository Tests**: Database operations
2. **Service Tests**: Business logic (mock repository and Kafka)
3. **Controller Tests**: REST endpoints (mock service)
4. **Integration Tests**: End-to-end flows

### Example Service Test
```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    @Mock
    private OrderRepository repository;
    
    @Mock
    private KafkaOrderProducer kafkaProducer;
    
    @InjectMocks
    private OrderService service;
    
    @Test
    void createOrder_shouldSaveAndPublishEvent() {
        // Given
        Order order = new Order(...);
        when(repository.save(any())).thenReturn(order);
        
        // When
        Order result = service.createOrder(order);
        
        // Then
        verify(repository).save(any());
        verify(kafkaProducer).sendOrderEvent(any());
        assertNotNull(result.getId());
    }
}
```

## Commit Guidelines

Follow conventional commits format:

```
feat: Add Order Service with CRUD operations
fix: Handle null pointer in order validation
docs: Update README with Order Service endpoints
refactor: Extract common validation logic
test: Add integration tests for order creation
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## Common Pitfalls to Avoid

1. **Don't hardcode values**: Use `application.yml` for configuration
2. **Don't skip validation**: Always validate user input
3. **Don't forget timestamps**: Set `createdAt` and `updatedAt` in service layer
4. **Don't publish events before saving**: Save to DB first, then publish events
5. **Don't log sensitive data**: Avoid logging passwords, tokens, etc.
6. **Don't use same ports**: Each service needs a unique port
7. **Don't share databases**: Each service gets its own MongoDB instance

## Getting Help

- Check existing Product Service implementation as a reference
- Review Swagger documentation at `/swagger-ui.html`
- Check service status with `.\scripts\<service>-service.ps1 --status`
- View logs for troubleshooting

## Quick Reference

### Port Allocation
- Product Service: 7070
- Order Service: 8080
- User Service: 8081
- API Gateway: 9000

### MongoDB Ports
- Product Service: 27018
- Order Service: 27019
- User Service: 27020

### Shared Infrastructure
- Kafka: 9092
- Zookeeper: 2181

### Useful Commands
```powershell
# Service management
.\scripts\<service>-service.ps1 --start|--stop|--status

# All services
.\scripts\manage-all.ps1 --start|--stop|--status

# Data seeding (Product Service)
.\tools\seed-products.ps1 seed|clear|reseed

# Build and run
mvn clean install -DskipTests
mvn spring-boot:run

# View logs
docker logs <container-name>
```

---

Happy coding! Follow the patterns established in Product Service, and your new service will integrate seamlessly with the platform.

