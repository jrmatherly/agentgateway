# 0003. Single Binary Deployment Model

Date: 2024-11-01

## Status

✅ Accepted

## Context

Agentgateway needs a deployment model that balances simplicity, performance, and operational overhead. The system includes multiple components: proxy engine, web UI, admin APIs, configuration management, and observability features.

Key considerations:
- **Operational Simplicity**: Minimize deployment complexity and operational overhead
- **Resource Efficiency**: Optimal resource utilization without over-provisioning
- **Development Velocity**: Faster development and testing cycles
- **Distribution**: Easy distribution and installation across platforms
- **Container Support**: Container-friendly deployment without bloat

Current industry trends show movement toward both microservices (for scalability) and single-binary distributions (for simplicity).

## Decision

We will implement Agentgateway as a **single binary** that includes all components:

- **Core Proxy**: Rust-based proxy engine with all protocol support
- **Web UI**: Next.js application compiled to static assets and embedded
- **Admin APIs**: Management and monitoring APIs served by the same binary
- **Configuration Manager**: Local and xDS configuration handling
- **Observability**: Metrics, tracing, and logging integrated

The binary will be configurable to enable/disable specific features as needed.

## Alternatives Considered

### Alternative 1: Microservices Architecture
- **Description**: Separate binaries for proxy, UI, admin API, and configuration service
- **Pros**: 
  - Independent scaling of components
  - Technology diversity (different languages per service)
  - Fault isolation between services
  - Team autonomy for different services
- **Cons**: 
  - Increased operational complexity (multiple deployments)
  - Network latency between services
  - Distributed tracing and debugging complexity
  - Service discovery and load balancing overhead
  - Higher resource usage due to process overhead
- **Rejection Reason**: Operational complexity outweighs benefits for our use case

### Alternative 2: Sidecar Pattern
- **Description**: Core proxy as main container with UI and admin as sidecar containers
- **Pros**:
  - Clear separation of concerns
  - Independent updates for non-critical components
  - Kubernetes-native deployment pattern
- **Cons**:
  - Increased pod resource requirements
  - Network configuration complexity
  - Additional container images to maintain
  - Service mesh complexity
- **Rejection Reason**: Adds complexity without significant benefits over single binary

### Alternative 3: Plugin Architecture
- **Description**: Core proxy with dynamically loaded plugins for UI and admin features
- **Pros**:
  - Extensible architecture
  - Optional features can be omitted
  - Third-party plugin development possible
- **Cons**:
  - Plugin interface stability and versioning complexity
  - Runtime loading security concerns
  - Distribution and dependency management challenges
  - Performance overhead of plugin boundaries
- **Rejection Reason**: Complexity exceeds benefits for current feature set

## Consequences

### Positive
- **Operational Simplicity**: Single binary to deploy, configure, and monitor
- **Resource Efficiency**: No inter-process communication overhead
- **Fast Startup**: Single process startup with shared memory space
- **Distribution**: Easy to package and distribute across platforms
- **Development Velocity**: Simplified development, testing, and debugging
- **Container Optimization**: Minimal container image size and attack surface
- **Shared State**: Efficient sharing of configuration and runtime state
- **Atomic Deployments**: Single atomic deployment unit

### Negative  
- **Binary Size**: Larger binary due to embedded UI assets
- **Memory Usage**: All components loaded in memory even if unused
- **Technology Constraints**: All components must use compatible technologies
- **Blast Radius**: Single point of failure for all functionality
- **Update Granularity**: Cannot update components independently
- **Resource Scaling**: Cannot scale components independently

### Neutral
- **Feature Flags**: Can disable unused features via configuration
- **Process Management**: Single process to monitor and manage
- **Port Management**: Single set of ports to configure and manage

## Implementation Notes

### UI Embedding Strategy
- **Build Process**: UI built as static assets during Rust compilation
- **Asset Embedding**: Use `include_dir!` macro to embed assets at compile time
- **Serving**: Serve embedded assets via Rust HTTP server (Tower/Axum)
- **Development Mode**: Optional file serving for development hot reload

### Configuration Architecture
```rust
#[derive(Clone)]
pub struct Config {
    pub ui_enabled: bool,
    pub admin_enabled: bool,
    pub metrics_enabled: bool,
    // ... other feature flags
}
```

### Feature Flag System
- **Compile-Time Features**: Cargo features for optional components
- **Runtime Configuration**: Enable/disable features via configuration
- **Graceful Degradation**: Disable features without breaking core functionality

### Binary Size Optimization
- **Asset Compression**: Compress embedded UI assets
- **Dead Code Elimination**: Use `strip` and `lto` for release builds
- **Feature Compilation**: Conditional compilation for optional features
- **Dependency Optimization**: Minimize transitive dependencies

### Memory Management
- **Lazy Loading**: Load UI assets only when UI is accessed
- **Shared State**: Use `Arc<T>` for sharing state between components
- **Memory Pools**: Reuse allocations where possible

## Acceptance Criteria

- [x] Single binary contains all necessary components
- [x] UI assets successfully embedded and served
- [x] Feature flags work to enable/disable components
- [x] Binary size optimized for distribution
- [x] Memory usage reasonable across all components
- [x] Development workflow supports UI hot reload
- [x] Container image size minimized

## References

- [Rust embedded assets](https://docs.rs/include_dir/)
- [Next.js static export](https://nextjs.org/docs/app/building-your-application/deploying/static-exports)
- [Cargo features documentation](https://doc.rust-lang.org/cargo/reference/features.html)
- [Binary size optimization](https://github.com/johnthagen/min-sized-rust)

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2024-11-01 | Architecture Team | Initial decision |