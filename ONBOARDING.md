# Agentgateway Developer Onboarding Guide

Welcome to the Agentgateway project! This comprehensive guide will help you get up to speed with the codebase, architecture, and development workflow.

## Table of Contents
- [Project Overview](#project-overview)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Key Components](#key-components)
- [Development Workflow](#development-workflow)
- [Architecture Decisions](#architecture-decisions)
- [Common Tasks](#common-tasks)
- [Potential Gotchas](#potential-gotchas)
- [Documentation and Resources](#documentation-and-resources)
- [Onboarding Checklist](#onboarding-checklist)

## Project Overview

**Agentgateway** is an open-source data plane optimized for agentic AI connectivity. It provides drop-in security, observability, and governance for agent-to-agent and agent-to-tool communication.

### Key Features
- **High Performance**: Written in Rust, designed for scale
- **Security First**: Robust RBAC system for MCP/A2A protocols
- **Multi-tenant**: Support for multiple tenants with isolated resources
- **Dynamic Configuration**: xDS-based configuration updates without downtime
- **Legacy API Support**: Transform legacy APIs into MCP resources (OpenAPI support)
- **Protocol Support**: [Agent2Agent (A2A)](https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/) and [Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction)

### Tech Stack
- **Core Language**: Rust 1.89+ (backend/proxy)
- **Frontend**: Next.js 15.5+ with React 19.1+, TypeScript 5+
- **UI Components**: Radix UI, Tailwind CSS 4.1+
- **Build Tools**: Cargo (Rust), npm (Node.js)
- **Protocols**: gRPC, HTTP/2, WebSockets
- **Configuration**: YAML, JSON Schema validation
- **Testing**: Cargo test, npm test, Docker-based validation

## Repository Structure

### Top-Level Directories

```
├── crates/           # Rust workspace crates (core business logic)
├── ui/              # Next.js frontend application
├── examples/        # Example configurations and use cases
├── schema/          # JSON schemas for configuration validation
├── go/              # Go protobuf bindings
├── common/          # Shared scripts and tools
├── .github/         # GitHub Actions CI/CD workflows
├── manifests/       # Kubernetes/deployment manifests
└── architecture/    # Architecture documentation and diagrams
```

### Crates Structure (Rust Workspace)

```
crates/
├── agentgateway-app/    # Main binary and CLI interface
├── agentgateway/        # Core proxy logic and HTTP handling
├── core/               # Shared utilities and telemetry
├── hbone/              # HBONE tunneling protocol
├── xds/                # xDS configuration management
├── a2a-sdk/            # Agent2Agent SDK
├── mock-server/        # Testing utilities
└── xtask/              # Build automation tasks
```

### UI Structure (Next.js)

```
ui/
├── src/             # Source code
├── public/          # Static assets
├── components.json  # Radix UI configuration
└── next.config.ts   # Next.js configuration
```

### Key Configuration Files
- `Cargo.toml` - Rust workspace configuration
- `Makefile` - Build and development commands
- `rust-toolchain.toml` - Rust version specification
- `examples/` - Configuration examples for different use cases

## Getting Started

### Prerequisites
- **Rust**: 1.89+ (specified in `rust-toolchain.toml`)
- **Node.js**: 23+ with npm 10+
- **Go**: 1.24+ (for protobuf generation)
- **Git**: For version control
- **Docker**: Optional, for containerized builds

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/agentgateway/agentgateway.git
   cd agentgateway
   ```

2. **Build the UI**
   ```bash
   cd ui
   npm install
   npm run build
   cd ..
   ```

3. **Build the Rust binary**
   ```bash
   CARGO_NET_GIT_FETCH_WITH_CLI=true make build
   ```

4. **Run the application**
   ```bash
   ./target/release/agentgateway
   ```

5. **Access the UI**
   Open http://localhost:15000/ui in your browser

### Running Tests
```bash
# Run Rust tests
make test

# Run validation tests
make validate

# Run linting
make lint
```

### Development Commands
```bash
# Format and fix linting issues
make fix-lint

# Generate schemas and APIs
make gen

# Clean build artifacts
make clean

# Docker build
make docker
```

## Key Components

### Entry Points
- **`crates/agentgateway-app/src/main.rs`** - Main binary entry point
- **`crates/agentgateway/src/app.rs`** - Core application runner
- **`crates/agentgateway/src/lib.rs`** - Library exports and modules

### Core Business Logic

#### Configuration Management
- **`crates/agentgateway/src/config/`** - Configuration parsing and validation
- **`schema/`** - JSON schemas for config validation
- **`examples/`** - Example configurations

#### Protocol Handlers
- **`crates/agentgateway/src/mcp/`** - Model Context Protocol implementation
- **`crates/agentgateway/src/a2a/`** - Agent2Agent protocol support
- **`crates/agentgateway/src/http/`** - HTTP routing and middleware

#### Core Systems
- **`crates/agentgateway/src/proxy/`** - Core proxy logic
- **`crates/agentgateway/src/transport/`** - Network transport layer
- **`crates/agentgateway/src/state_manager/`** - State management
- **`crates/xds/`** - xDS configuration discovery

#### Security & Observability
- **`crates/agentgateway/src/http/authorization*`** - Authorization policies
- **`crates/agentgateway/src/telemetry/`** - Metrics and tracing
- **`crates/core/src/trcng.rs`** - Tracing configuration

## Development Workflow

### Git Workflow
- **Main Branch**: `main`
- **Feature Branches**: Create from `main`, name descriptively
- **Pull Requests**: Required for all changes to `main`

### Code Standards
- **Rust**: Follow `rustfmt` formatting, pass `clippy` lints
- **TypeScript**: ESLint + Prettier configuration in `ui/`
- **Commit Messages**: Clear, descriptive commit messages

### CI/CD Pipeline
- **`.github/workflows/pull_request.yml`** - PR validation
- **`.github/workflows/release.yml`** - Release builds
- **Tests**: Unit tests, integration tests, validation tests
- **Builds**: Multi-platform builds (Linux, macOS, Windows, ARM64)

### Testing Strategy
- **Unit Tests**: Embedded in source files (`*_test.rs`, `tests.rs`)
- **Integration Tests**: Example configurations validation
- **Benchmarks**: Performance tests in `benches/`
- **E2E Tests**: Docker-based validation

### Release Process
- Version managed in `Cargo.toml` workspace
- Automated releases via GitHub Actions
- Multi-platform binary distributions

## Architecture Decisions

### Design Patterns
- **Modular Architecture**: Clear separation between protocols, transport, and business logic
- **Plugin System**: Extensible middleware and filter system
- **Configuration-Driven**: Declarative YAML configuration with JSON Schema validation
- **Async/Await**: Tokio-based async runtime for high concurrency

### State Management
- **Arc<Config>**: Shared immutable configuration
- **Dynamic Updates**: Hot reloading via xDS without downtime
- **Resource Isolation**: Multi-tenant resource separation

### Security Architecture
- **Zero Trust**: All connections require explicit authorization
- **RBAC**: Role-based access control for MCP/A2A protocols
- **TLS Termination**: Built-in TLS support with certificate management
- **JWT Authentication**: Token-based authentication with policy enforcement

### Performance Optimizations
- **Rust Performance**: Zero-cost abstractions, minimal allocations
- **Connection Pooling**: HTTP/2 connection reuse
- **Memory Management**: jemalloc allocator on supported platforms
- **Async I/O**: Non-blocking I/O with Tokio

### Error Handling Strategy
- **Structured Errors**: `anyhow` for error chaining with context
- **Graceful Degradation**: Fallback mechanisms for partial failures
- **Observability**: Comprehensive error logging and metrics

## Common Tasks

### Adding a New Configuration Field
1. Update the relevant struct in `crates/agentgateway/src/lib.rs`
2. Add validation logic if needed
3. Update JSON schema in `schema/`
4. Add example usage in `examples/`
5. Run `make gen` to regenerate schemas

### Adding a New Protocol Handler
1. Create module in `crates/agentgateway/src/`
2. Implement protocol-specific logic
3. Register handler in routing system
4. Add configuration options
5. Create example in `examples/`
6. Add tests

### Adding a New API Endpoint
1. Add route in `crates/agentgateway/src/http/`
2. Implement handler function
3. Add authorization checks if needed
4. Update OpenAPI schema if applicable
5. Add integration tests

### Debugging Issues
1. Enable debug logging: `RUST_LOG=debug`
2. Use telemetry endpoints: `/stats`, `/ready`
3. Check configuration validation: `--validate-only`
4. Review example configurations
5. Use `make validate` for comprehensive checks

## Potential Gotchas

### Environment Setup
- **Rust Version**: Must use exactly version 1.89 (specified in `rust-toolchain.toml`)
- **Git CLI**: Set `CARGO_NET_GIT_FETCH_WITH_CLI=true` for building
- **Platform Differences**: musl vs glibc builds, Windows-specific configs

### Configuration Issues
- **Schema Validation**: Configuration must match JSON schema exactly
- **Port Conflicts**: Default port 15000 for UI, 3000 for proxy
- **Path Separators**: Use forward slashes in configuration paths

### Build Dependencies
- **Node.js Version**: Requires Node 23+ for UI builds
- **Protobuf**: Go protobuf tools needed for schema generation
- **musl-tools**: Required for Linux musl builds

### Testing Quirks
- **Validation Dependencies**: Some tests require external services
- **Windows Limitations**: Some features disabled on Windows builds
- **CI Environment**: Tests behave differently in CI vs local development

### Performance Considerations
- **jemalloc**: Performance significantly better with jemalloc allocator
- **Connection Limits**: Default HTTP/2 connection pooling settings
- **Memory Usage**: Large configurations can consume significant memory

## Documentation and Resources

### Existing Documentation
- **README.md** - Project overview and basic setup
- **DEVELOPMENT.md** - Local development instructions
- **examples/README.md** - Example configurations guide
- **CONTRIBUTION.md** - Contributing guidelines

### External Resources
- **Project Website**: https://agentgateway.dev/
- **Documentation**: https://agentgateway.dev/docs/
- **Community Discord**: https://discord.gg/BdJpzaPjHv
- **GitHub Issues**: https://github.com/agentgateway/agentgateway/issues

### API Documentation
- **Configuration Schema**: Generated from `schema/local.json`
- **REST APIs**: Auto-generated OpenAPI specs
- **Protocol Documentation**: MCP and A2A protocol references

### Architecture Documentation
- **Architecture Diagrams**: See `img/architecture.svg`
- **Design Documents**: Located in `architecture/` directory

## Onboarding Checklist

### Week 1: Environment Setup
- [ ] Set up development environment (Rust 1.89+, Node.js 23+)
- [ ] Clone repository and build successfully
- [ ] Run basic example configuration
- [ ] Access UI at http://localhost:15000/ui
- [ ] Run test suite successfully
- [ ] Join Discord community

### Week 2: Codebase Familiarization
- [ ] Read through main entry points and core modules
- [ ] Understand configuration system and examples
- [ ] Explore protocol handlers (MCP, A2A, HTTP)
- [ ] Review testing strategy and run specific test suites
- [ ] Study CI/CD workflow in `.github/workflows/`

### Week 3: First Contribution
- [ ] Identify area of interest (frontend, backend, docs, examples)
- [ ] Make small test change (e.g., add log message)
- [ ] Create feature branch and commit change
- [ ] Open draft PR to test CI pipeline
- [ ] Address any CI feedback and merge

### Week 4: Deep Dive
- [ ] Understand architecture patterns and design decisions
- [ ] Explore advanced features (authorization, telemetry, xDS)
- [ ] Contribute documentation improvements
- [ ] Participate in community discussions
- [ ] Start working on first substantial feature

### Ongoing Learning
- [ ] Stay updated with project roadmap
- [ ] Review other contributors' PRs
- [ ] Participate in community meetings
- [ ] Contribute examples and documentation
- [ ] Help other new contributors

## Next Steps

After completing this onboarding:

1. **Pick an area of focus** based on your interests and skills
2. **Start with small contributions** to build familiarity
3. **Engage with the community** through Discord and GitHub
4. **Read the contribution guidelines** in CONTRIBUTION.md
5. **Check the project roadmap** for upcoming features

Welcome to the Agentgateway community! 🚀