# E‑Commerce Platform

Product catalog microservice providing CRUD APIs with MongoDB persistence, Kafka events, and OpenAPI documentation.

## Tech Stack
- Spring Boot 3.2 (Java 17)
- Spring Data MongoDB
- Spring Kafka
- Springdoc OpenAPI (UI)
- Maven, Docker (Kafka/Zookeeper)

## Core Features
- Product REST API:
  - GET /api/products
  - GET /api/products/{id}
  - GET /api/products/category/{category}
  - POST /api/products
  - PUT /api/products/{id}
  - DELETE /api/products/{id}
- Bean Validation and standardized error responses
- Kafka events on topic "product-events" (publish on create/update/delete)
- Auto-generated OpenAPI/Swagger documentation

## Setup & Usage
- Prerequisites: Java 17+, Maven, Docker
- Start infrastructure:
  - docker compose up -d        # Kafka + Zookeeper
  - docker run -d --name product-mongodb -p 27018:27017 mongo:7.0
  - (Optional, Windows) .\scripts\product-service.ps1 --start
- Build and run:
  - mvn clean install -DskipTests
  - mvn spring-boot:run
- Defaults:
  - App: http://localhost:7070
  - MongoDB: http://localhost:27018 (database: product-db)
  - Kafka: https://localhost:9092
- Optional: seed sample data
  - .\tools\seed-products.ps1 seed

## API Documentation
- OpenAPI JSON: http://localhost:7070/api-docs
- Swagger UI: http://localhost:7070/swagger-ui.html

## Future Enhancements
Add pagination/filtering to list endpoints and integration tests to verify Kafka publish/consume flows.