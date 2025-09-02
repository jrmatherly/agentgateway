# Component Architecture (C4 Level 3)

## Overview

This document describes the internal component structure of Agentgateway, detailing the Rust crate organization, module dependencies, and key architectural patterns used throughout the system.

## Crate Architecture Diagram

```mermaid
graph TB
    subgraph "Application Layer"
        App[agentgateway-app<br/>CLI & Binary Entry Point]
    end
    
    subgraph "Core Gateway Logic"
        Gateway[agentgateway<br/>Core Proxy Logic]
    end
    
    subgraph "Foundation Libraries"
        Core[agent-core<br/>Shared Utilities]
        XDS[agent-xds<br/>Configuration Discovery]
        HBone[agent-hbone<br/>Tunneling Protocol]
    end
    
    subgraph "SDK & Extensions"
        A2ASDK[a2a-sdk<br/>Agent2Agent SDK]
        MockServer[mock-server<br/>Testing Utilities]
    end
    
    subgraph "Build & Development"
        XTask[xtask<br/>Build Automation]
    end
    
    App --> Gateway
    Gateway --> Core
    Gateway --> XDS
    Gateway --> HBone
    Gateway --> A2ASDK
    XDS --> Core
    HBone --> Core
    MockServer --> Core
    XTask -.-> Gateway
    
    classDef app fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef core fill:#f1f8e9,stroke:#388e3c,stroke-width:2px
    classDef foundation fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef sdk fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef build fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    
    class App app
    class Gateway core
    class Core,XDS,HBone foundation
    class A2ASDK,MockServer sdk
    class XTask build
```

## Core Crates

### agentgateway-app (Application Entry Point)

```mermaid
graph TB
    subgraph "agentgateway-app/src"
        Main[main.rs<br/>CLI & Bootstrap]
    end
    
    Main -->|Parses Args| Config[Configuration Loading]
    Main -->|Validates| Validation[Config Validation]
    Main -->|Runs| Runtime[Tokio Runtime]
    Main -->|Starts| Proxy[Proxy Application]
    
    Config -->|YAML/JSON| FileConfig[File Configuration]
    Config -->|Inline| StringConfig[String Configuration]
    Validation -->|Schema| JsonSchema[JSON Schema Validation]
    Runtime -->|Async| AsyncRuntime[Async Runtime Setup]
    Proxy -->|Arc Config| SharedConfig[Shared Configuration]
```

**Responsibilities**:
- Command-line argument parsing and validation
- Configuration loading from files or command-line
- Application bootstrap and lifecycle management
- Tokio runtime configuration and startup
- Graceful shutdown handling

**Key Components**:
- `main()` - Entry point with argument parsing
- `validate()` - Configuration validation logic
- `proxy()` - Main application runner
- `copy_binary()` - Utility for container deployment

### agentgateway (Core Gateway Logic)

```mermaid
graph TB
    subgraph "agentgateway/src"
        LibRoot[lib.rs<br/>Module Exports]
        
        subgraph "Request Processing"
            Proxy[proxy/<br/>Core Proxy Logic]
            HTTP[http/<br/>HTTP Handling]
            MCP[mcp/<br/>MCP Protocol]
            A2A[a2a/<br/>A2A Protocol]
        end
        
        subgraph "Infrastructure"
            Config[config/<br/>Configuration]
            Transport[transport/<br/>Network Transport]
            Client[client/<br/>Backend Clients]
        end
        
        subgraph "Cross-Cutting"
            Security[http/authorization*<br/>Security]
            Telemetry[telemetry/<br/>Observability]
            StateManager[state_manager/<br/>State]
        end
        
        subgraph "Supporting"
            Parse[parse/<br/>Request Parsing]
            CEL[cel/<br/>Expression Language]
            LLM[llm/<br/>AI Processing]
            Utils[util/<br/>Utilities]
        end
        
        subgraph "UI & Management"
            UI[ui/<br/>Web Interface]
            Management[management/<br/>Admin API]
        end
    end
    
    LibRoot --> Proxy
    LibRoot --> Config
    
    Proxy --> HTTP
    Proxy --> Transport
    HTTP --> MCP
    HTTP --> A2A
    HTTP --> Security
    
    Config --> Parse
    Transport --> Client
    Security --> CEL
    
    Proxy -.-> Telemetry
    Proxy -.-> StateManager
    Management --> UI
    
    classDef processing fill:#e8f5e8,stroke:#4caf50,stroke-width:2px
    classDef infra fill:#e3f2fd,stroke:#2196f3,stroke-width:2px
    classDef crosscut fill:#fff3e0,stroke:#ff9800,stroke-width:2px
    classDef support fill:#f3e5f5,stroke:#9c27b0,stroke-width:2px
    classDef ui fill:#fce4ec,stroke:#e91e63,stroke-width:2px
    
    class Proxy,HTTP,MCP,A2A processing
    class Config,Transport,Client infra
    class Security,Telemetry,StateManager crosscut
    class Parse,CEL,LLM,Utils support
    class UI,Management ui
```

#### Request Processing Components

##### proxy/ - Core Proxy Logic
- **gateway.rs**: Main request gateway and routing engine
- **httpproxy.rs**: HTTP-specific proxy implementation
- **tcpproxy.rs**: TCP-level proxy for non-HTTP protocols
- **request_builder.rs**: Request construction and transformation utilities

##### http/ - HTTP Protocol Handling
- **mod.rs**: HTTP module exports and routing setup
- **route_test.rs**: Route matching and selection logic
- **filters_test.rs**: Request/response filtering pipeline
- **transformation*.rs**: Request/response transformation logic
- **authorization*.rs**: HTTP-level authorization and security
- **retry/**: Retry logic and failure handling

##### mcp/ - Model Context Protocol
- **mod.rs**: MCP protocol implementation entry point
- **openapi/**: OpenAPI to MCP transformation logic
- **tests.rs**: MCP protocol test suite
- Transport adapters for stdio, HTTP, WebSocket

##### a2a/ - Agent2Agent Protocol
- **mod.rs**: A2A protocol implementation
- **tests.rs**: A2A protocol test suite
- RESTful agent-to-agent communication patterns

#### Infrastructure Components

##### config/ - Configuration Management
- **mod.rs**: Configuration loading and parsing
- **parse_config()**: YAML/JSON configuration parser
- Schema validation and merging logic
- Hot-reload file watching

##### transport/ - Network Transport Layer
- **mod.rs**: Transport abstraction layer
- Connection pooling and management
- Protocol-agnostic transport implementations
- TLS and security transport wrappers

##### client/ - Backend Client Management
- **mod.rs**: Backend client abstraction
- **dns_tests.rs**: DNS resolution and service discovery
- HTTP client pool management
- Connection health checking and circuit breaking

#### Cross-Cutting Components

##### Security (http/authorization*)
- **authorization_tests.rs**: Authorization policy testing
- RBAC policy evaluation engine
- JWT token validation and parsing
- Multi-tenant security isolation

##### telemetry/ - Observability
- **mod.rs**: Telemetry setup and configuration
- **log.rs**: Structured logging configuration
- **trc.rs**: Distributed tracing setup
- Metrics collection and export

##### state_manager/ - Runtime State
- **mod.rs**: In-memory state management
- Thread-safe state sharing (Arc<RwLock>)
- Configuration state and runtime metrics
- Connection tracking and lifecycle

### Foundation Libraries

#### agent-core (Shared Utilities)

```mermaid
graph TB
    subgraph "agent-core/src"
        CoreLib[lib.rs]
        
        Version[version.rs<br/>Build Info]
        Telemetry[telemetry.rs<br/>Tracing Setup]
        Tracing[trcng.rs<br/>Trace Config]
        Utils[Shared Utilities]
    end
    
    CoreLib --> Version
    CoreLib --> Telemetry
    CoreLib --> Tracing
    CoreLib --> Utils
    
    Version -->|Build Time| BuildInfo[Build Information]
    Telemetry -->|Setup| LoggingSetup[Logging Setup]
    Tracing -->|Config| TracingConfig[Tracing Configuration]
```

**Responsibilities**:
- Build information and version management
- Shared telemetry and logging setup
- Common utilities across all crates
- Version information for runtime introspection

#### agent-xds (Configuration Discovery)

```mermaid
graph TB
    subgraph "agent-xds/src"
        XDSLib[lib.rs]
        
        Client[client.rs<br/>xDS Client]
        Config[Configuration Types]
        Protocol[xDS Protocol]
    end
    
    XDSLib --> Client
    XDSLib --> Config
    XDSLib --> Protocol
    
    Client -->|gRPC| ControlPlane[Control Plane]
    Config -->|Validation| ConfigSchema[Config Schema]
    Protocol -->|Envoy| XDSProtocol[xDS Protocol Types]
```

**Responsibilities**:
- xDS protocol client implementation
- Configuration discovery from control plane
- Dynamic configuration updates
- Protocol buffer message handling

#### agent-hbone (Tunneling Protocol)

```mermaid
graph TB
    subgraph "agent-hbone/src"
        HBoneLib[lib.rs]
        
        Tunnel[Tunneling Logic]
        Config[HBONE Configuration]
        Transport[Transport Layer]
    end
    
    HBoneLib --> Tunnel
    HBoneLib --> Config
    HBoneLib --> Transport
    
    Tunnel -->|Secure| SecureTunnel[Secure Tunneling]
    Config -->|Settings| TunnelConfig[Tunnel Configuration]
    Transport -->|Network| NetworkTransport[Network Transport]
```

**Responsibilities**:
- HBONE (HTTP-Based Overlay Network Encapsulation) protocol
- Secure tunneling between components
- Network overlay management
- Transport-level encryption and authentication

## Module Dependencies and Patterns

### Dependency Hierarchy

```mermaid
graph TB
    subgraph "Layer 4: Application"
        App4[agentgateway-app]
    end
    
    subgraph "Layer 3: Core Logic"
        Gateway3[agentgateway]
        SDK3[a2a-sdk]
    end
    
    subgraph "Layer 2: Foundation Services"
        XDS2[agent-xds]
        HBone2[agent-hbone]
    end
    
    subgraph "Layer 1: Shared Utilities"
        Core1[agent-core]
    end
    
    App4 --> Gateway3
    Gateway3 --> XDS2
    Gateway3 --> HBone2
    Gateway3 --> Core1
    XDS2 --> Core1
    HBone2 --> Core1
    SDK3 --> Core1
    
    classDef layer1 fill:#e8f5e8
    classDef layer2 fill:#e3f2fd
    classDef layer3 fill:#fff3e0
    classDef layer4 fill:#fce4ec
    
    class Core1 layer1
    class XDS2,HBone2 layer2
    class Gateway3,SDK3 layer3
    class App4 layer4
```

### Key Architectural Patterns

#### 1. Layered Architecture
- **Application Layer**: CLI and bootstrap logic
- **Core Logic**: Business logic and protocol handling
- **Foundation Services**: Infrastructure and utilities
- **Shared Utilities**: Common functionality across layers

#### 2. Modular Plugin Architecture
- **Protocol Adapters**: Pluggable protocol implementations
- **Transport Adapters**: Multiple transport layer options
- **Filter Pipeline**: Configurable request/response filters
- **Policy Engines**: Pluggable authorization and routing policies

#### 3. Async/Await Patterns
- **Tokio Runtime**: Single-threaded or multi-threaded async runtime
- **Async Traits**: Protocol-agnostic async interfaces
- **Stream Processing**: Async stream handling for WebSocket/gRPC
- **Concurrent Processing**: Parallel request handling with shared state

#### 4. Configuration-Driven Design
- **Declarative Configuration**: YAML/JSON configuration files
- **Schema Validation**: JSON Schema validation for all config
- **Hot Reload**: File-watching for configuration changes
- **Precedence Rules**: Clear configuration override hierarchy

#### 5. Error Handling Strategy
- **anyhow**: Error context and chaining throughout the system
- **thiserror**: Custom error types with structured information
- **Result Types**: Explicit error handling at all boundaries
- **Graceful Degradation**: Continue operation during partial failures

#### 6. Thread Safety and State Management
- **Arc<RwLock>**: Shared state with read-write locking
- **Atomic Operations**: Lock-free counters and flags
- **Message Passing**: Channel-based communication between components
- **Immutable Configuration**: Copy-on-write configuration updates

## Testing Architecture

### Test Organization

```mermaid
graph TB
    subgraph "Test Types"
        Unit[Unit Tests<br/>*_test.rs, tests.rs]
        Integration[Integration Tests<br/>tests/ directory]
        Bench[Benchmarks<br/>benches/]
        Examples[Example Tests<br/>examples/*/]
    end
    
    Unit -->|Mock| MockServer[mock-server crate]
    Integration -->|Real| RealServices[Real Backend Services]
    Bench -->|Performance| PerfMetrics[Performance Metrics]
    Examples -->|Validation| ConfigValidation[Config Validation]
    
    classDef test fill:#e8f5e8,stroke:#4caf50
    classDef support fill:#f3e5f5,stroke:#9c27b0
    
    class Unit,Integration,Bench,Examples test
    class MockServer,RealServices,PerfMetrics,ConfigValidation support
```

### Testing Patterns

#### Unit Testing
- **Embedded Tests**: Tests alongside source code in same file
- **Mock Backends**: Use mock-server crate for external dependencies
- **Property Testing**: Randomized testing for edge cases
- **Async Testing**: tokio::test for async function testing

#### Integration Testing
- **Docker Compose**: Real backend services for integration tests
- **Configuration Testing**: Validate example configurations
- **End-to-End**: Full request lifecycle testing
- **Performance Testing**: Benchmarks and load testing

## Build and Development Architecture

### Build System
- **Cargo Workspace**: Multi-crate project organization
- **Feature Flags**: Conditional compilation for different deployments
- **Cross Compilation**: Support for multiple platforms and architectures
- **Optimization Profiles**: Different optimization levels for dev/release

### Development Tools
- **xtask**: Custom build automation and development tasks
- **Schema Generation**: Automatic JSON schema generation from types
- **API Generation**: Protocol buffer and OpenAPI generation
- **Linting**: Comprehensive linting with clippy and rustfmt

### CI/CD Integration
- **GitHub Actions**: Automated testing and building
- **Multi-Platform**: Build for Linux, macOS, Windows, ARM64
- **Docker**: Containerized builds and deployments
- **Release Automation**: Automated release management and distribution