<center>

# AlgaShop

![Java](https://img.shields.io/badge/Java-21-ED8B00?logo=java&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4-6DB33F?logo=springboot&logoColor=white)
![Gradle](https://img.shields.io/badge/Gradle-8.0-02303A?logo=gradle&logoColor=white)
![JUnit 5](https://img.shields.io/badge/JUnit%205-5.10-25A162?logo=junit5&logoColor=white)
![Lombok](https://img.shields.io/badge/Lombok-1.18.30-red?logo=lombok&logoColor=white)

</center>

An e-commerce platform built with Domain-Driven Design principles, featuring multiple microservices for order management, customer handling, and business operations.

## Overview

AlgaShop consists of the following services:

- **Ordering** ([microservices/ordering/README.md](./microservices/ordering/README.md)) - Customer and order management API (currently in development)

More services will be added as the platform evolves.

## Features

### Customer Management
- **Rich Domain Model**: Customer entity with comprehensive business logic including archiving, loyalty points management, and promotion notifications
- **Value Objects**: Strongly-typed value objects for Email, Phone, Document, Birthdate, FullName, and CustomerId ensuring data integrity
- **Domain Validation**: Built-in validation framework with custom exceptions and error messages
- **Business Rules**: Enforced business rules for customer state changes and operations

### Domain-Driven Design Implementation
- **Entity Management**: Customer entity with proper identity management and business invariants
- **Value Objects**: Immutable value objects for domain concepts with validation logic
- **Domain Exceptions**: Custom exception hierarchy for business rule violations
- **Utility Services**: ID generation and field validation utilities

## Architecture

The ordering microservice follows Domain-Driven Design principles:

### Domain Layer Structure
- **Entities**: Core business objects with identity (`Customer`)
- **Value Objects**: Immutable objects without identity (`Email`, `Phone`, `Document`, `Birthdate`, `FullName`, `CustomerId`, `LoyaltyPoints`)
- **Domain Exceptions**: Business rule violations (`CustomerArchivedException`, `DomainException`)
- **Validation**: Field validation framework (`FieldValidator`)
- **Utilities**: Domain-specific helper services (`IdGenerator`)

### Key Domain Concepts
- **Customer Lifecycle**: Registration, updates, archiving with proper state management
- **Loyalty Points**: Accumulation and management system for customer rewards
- **Privacy Controls**: Promotion notification preferences and data archiving
- **Validation Rules**: Comprehensive input validation for all customer data

## Development

### Local Development

For development, run the ordering microservice:

1. Navigate to the ordering service:

   ```bash
   cd microservices/ordering
   ```

2. Build the project:

   ```bash
   ./gradlew build
   ```

3. Run the application:

   ```bash
   ./gradlew bootRun
   ```

4. Run tests:

   ```bash
   ./gradlew test
   ```

### Testing

The project includes comprehensive unit testing:

- **Domain Tests**: Full coverage of domain entities and value objects
- **Validation Tests**: Test all validation scenarios and edge cases
- **Business Rule Tests**: Verify domain invariants and business logic
- **Test Configuration**: Detailed test logging with full exception traces

### Build

Build the entire project:

```bash
./gradlew build
```

Run with specific profile:

```bash
./gradlew bootRun --args='--spring.profiles.active=dev'
```