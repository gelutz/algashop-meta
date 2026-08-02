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
- **Product Catalog** ([microservices/product-catalog/README.md](./microservices/product-catalog/README.md)) - Product and category catalog API, developed with Consumer-Driven Contracts (Spring Cloud Contract)

More services will be added as the platform evolves.

Each microservice is self-contained and carries its own Gradle wrapper — there is no build at the repository root.

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

### Running the product-catalog stubs

The product-catalog service is built with Consumer-Driven Contracts. Its contracts generate WireMock stubs that stand in for the real service, so consumers (and manual API exploration) can work against it without a database or any of its runtime dependencies.

**1. Build the stubs.** They are generated into `build/stubs/`, which is not checked in:

```bash
cd microservices/product-catalog
./gradlew build
```

**2. Start the stub server** from the repository root — it listens on port **8089**:

```bash
docker compose up product-catalog-stub
```

The compose service mounts the generated mappings directly into a stock `wiremock/wiremock:3x` container:

```yaml
product-catalog-stub:
  image: wiremock/wiremock:3x
  ports:
    - "8089:8080"
  volumes:
    - ./microservices/product-catalog/build/stubs/META-INF/com.lutz.algashop/product-catalog/0.0.1-SNAPSHOT/mappings:/home/wiremock/mappings
  command: --verbose --disable-http2-plain
```

The container serves whatever JSON is on disk at the mount point. **After changing a contract, re-run `./gradlew build`** — restarting the container by itself will not pick up the change, and `--build` does nothing here since the service uses a stock image rather than a Dockerfile.

If `build/stubs/` does not exist, the mount resolves to an empty directory and every request returns 404.

#### Alternative: Spring Cloud Stub Runner

The plain WireMock container works because the generated mappings are already unpacked as ordinary WireMock JSON. Spring Cloud's Stub Runner is the other option — it resolves a stubs JAR by Maven coordinates and hosts it itself:

```yaml
product-catalog-stub:
  image: springcloud/spring-cloud-contract-stub-runner
  ports:
    - "8089:8080"
  volumes:
    - ./microservices/product-catalog/build/stubs:/stubs
  environment:
    stubrunner.ids: com.lutz.algashop:product-catalog:0.0.1-SNAPSHOT:stubs:8089
    stubrunner.repository-root: file://stubs
    stubrunner.stubs-mode: LOCAL
```

It is worth the extra configuration only if you need coordinate-based stub resolution or the runner's HTTP control endpoints. For consumer *tests*, prefer wiring Stub Runner into the consumer service directly with `@AutoConfigureStubRunner` rather than running either container.

### API requests (Bruno)

The [`bruno-requests/`](./bruno-requests) collection holds ready-made requests against the local stubs and mocks:

| Request | Target | Description |
|---------|--------|-------------|
| `Product Catalog Stub - create product` | `localhost:8089` | `POST /api/v1/products` against the product-catalog stub |
| `Product Catalog Stub - find product by id` | `localhost:8089` | `GET /api/v1/products/{id}` against the product-catalog stub |
| `AlgaShop Wiremock Request` | `localhost:8780` | `POST /api/delivery-cost` against the RapidEx delivery mock |

Start the matching service before running a request — the product-catalog ones need `docker compose up product-catalog-stub`, and `AlgaShop Wiremock Request` needs the `rapidexapi` service.

Stub requests must match their contract exactly: method, path, headers and body are all part of the match. When a request does not match, WireMock responds with a side-by-side diff of the expected matchers against what it actually received — read that diff before suspecting the service code, since it usually points straight at the field that differs.

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

## TODO

- Update ordering README with new tests info (presentation)
- Update microservices README to have the same badges and layout as the meta README
- Document product-catalog category endpoints once implemented (contracts dir exists, no contracts yet)