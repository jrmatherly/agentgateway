# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**Agentgateway** is a high-performance data plane for agentic AI connectivity, supporting Agent2Agent (A2A) and Model Context Protocol (MCP). It's built as a multi-crate Rust workspace with a Next.js TypeScript frontend.

## Development Commands

### Building
```bash
# Build frontend first (required for UI feature)
cd ui && npm install && npm run build && cd ..

# Build agentgateway binary with UI
make build
# Equivalent to: cargo build --release --features ui

# Build for development
cargo build

# Build specific target/profile
make build-target TARGET=<target> PROFILE=<profile>
```

### Testing
```bash
# Run all tests
make test
# Equivalent to: cargo test --all-targets

# Run specific test
cargo test <test_name>

# Run tests for specific crate
cargo test -p <crate_name>
```

### Linting and Formatting
```bash
# Check formatting and run clippy
make lint
# Equivalent to: cargo fmt --check && cargo clippy --all-targets -- -D warnings

# Auto-fix issues
make fix-lint
# Equivalent to: cargo clippy --fix --allow-staged --allow-dirty --workspace && cargo fmt

# Frontend linting
cd ui && npm run lint
```

### Code Generation
```bash
# Generate APIs and schema
make gen
# Equivalent to: make generate-apis generate-schema fix-lint

# Generate schema only
make generate-schema
# Equivalent to: cargo xtask schema

# Generate APIs only (requires buf)
make generate-apis
```

### Running
```bash
# Run agentgateway with default config
./target/release/agentgateway

# Run with specific config
./target/release/agentgateway -f examples/basic/config.yaml

# Validate config only
./target/release/agentgateway -f <config.yaml> --validate-only

# Run validation deps for testing
make run-validation-deps
# Stop validation deps
make stop-validation-deps
```

### Development Server
```bash
# Frontend development (with Turbopack)
cd ui && npm run dev

# Access UI at http://localhost:15000/ui after building and running agentgateway
```

## Architecture

### Crate Structure

The project uses a Rust workspace with these key crates:

- **`agentgateway-app`**: Main binary entry point (`agentgateway` executable)
- **`agentgateway`**: Core gateway logic with protocol implementations
- **`agent-core`**: Shared utilities, telemetry, and core abstractions
- **`a2a-sdk`**: Agent2Agent protocol SDK
- **`agent-hbone`**: HBONE tunneling protocol implementation
- **`agent-xds`**: xDS configuration management for dynamic updates
- **`hyper-util-fork`**: Forked hyper utilities for custom networking needs

### Protocol Support

The gateway implements multiple protocols:

- **MCP (Model Context Protocol)**: Via `rmcp` dependency with stdio, SSE, and HTTP transports
- **A2A (Agent2Agent)**: Custom protocol for agent-to-agent communication
- **HTTP/HTTP2**: Standard web protocols with full feature support
- **OpenAPI**: Legacy API transformation into MCP resources

### Configuration Architecture

- **Static**: YAML-based configuration files (see `examples/` directory)
- **Dynamic**: xDS protocol support for runtime configuration updates without restarts
- **Multi-tenant**: Each tenant gets isolated resources and configurations

### Core Features Implementation

- **RBAC**: JWT-based authentication with policy-driven authorization
- **Observability**: OpenTelemetry integration with Prometheus metrics
- **TLS**: Rustls-based TLS termination and mutual TLS
- **Rate Limiting**: Built-in request throttling capabilities
- **CORS**: Configurable cross-origin resource sharing

### Frontend Architecture

Next.js 15 app with:
- **React 19**: Latest React with concurrent features
- **Radix UI**: Accessible component primitives
- **Tailwind v4**: Utility-first CSS framework
- **TypeScript**: Full type safety across the stack

## Configuration Examples

Configuration files are in `examples/` directory, starting with `basic/config.yaml` for simple setups. Each example builds in complexity:

1. `basic/` - Single MCP server over stdio
2. `multiplex/` - Multiple targets on single listener
3. `authorization/` - JWT auth with policies
4. `tls/` - TLS termination
5. `openapi/` - Legacy API transformation

## Key Dependencies

### Rust Backend
- **Web Framework**: `axum` with `tower` middleware
- **Async Runtime**: `tokio` with full features
- **HTTP**: `hyper` with HTTP/2 support
- **TLS**: `rustls` with ring crypto
- **JSON/YAML**: `serde` with preservation features
- **Observability**: `tracing` + `opentelemetry`

### Protocol Libraries
- **MCP**: `rmcp` with multiple transports
- **gRPC**: `tonic` with protobuf support
- **WebSocket**: Built-in via axum

### Performance Features
- Optional jemalloc via `jemalloc` feature flag
- CPU affinity control via `core_affinity`
- Async compression with multiple algorithms

## Build Features

Key feature flags:
- `ui`: Embeds frontend assets (required for web UI)
- `jemalloc`: Uses jemalloc for better memory management
- `tls-ring`: Ring-based TLS (default)
- `schema`: Enables schema generation
- `testing`: Test utilities

## Common Workflows

### Adding New Protocol Support
1. Define protocol in `crates/agentgateway/src/` 
2. Update transport layer in relevant modules
3. Add configuration schema
4. Update main application routing

### Extending Configuration
1. Add fields to config structs in `crates/agentgateway/src/config.rs`
2. Update schema generation: `make generate-schema`
3. Add example in `examples/` directory

### Testing Changes
1. Run unit tests: `cargo test`
2. Validate example configs: `make validate`
3. Test frontend: `cd ui && npm test`
4. Integration testing requires `make run-validation-deps`