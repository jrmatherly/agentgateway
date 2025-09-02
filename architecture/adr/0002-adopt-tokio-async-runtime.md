# 0002. Adopt Tokio for Async Runtime

Date: 2024-10-15

## Status

✅ Accepted

## Context

Agentgateway needs to handle thousands of concurrent connections efficiently while maintaining low latency. The proxy must support multiple protocols (HTTP, WebSocket, gRPC) and manage connections to various backend services simultaneously.

Key requirements:
- **High Concurrency**: Handle thousands of simultaneous connections
- **Low Latency**: Minimize request processing overhead
- **Protocol Support**: HTTP/1.1, HTTP/2, WebSocket, gRPC
- **Resource Efficiency**: Minimal memory and CPU usage per connection
- **Async I/O**: Non-blocking I/O operations for optimal performance

Rust provides several async runtime options, and we need to choose the one that best fits our needs.

## Decision

We will use **Tokio** as the async runtime for Agentgateway with the following configuration:

- **Runtime Type**: Multi-threaded runtime for CPU-intensive operations
- **Worker Threads**: Configurable thread pool (default: number of CPU cores)
- **I/O Driver**: Tokio's epoll/kqueue-based I/O driver
- **Timer**: Tokio's timer wheel for efficient timeout handling
- **Networking**: Tokio's networking primitives (TcpStream, TcpListener)

## Alternatives Considered

### Alternative 1: async-std
- **Description**: Alternative async runtime with std-like APIs
- **Pros**: 
  - Familiar std-like API design
  - Good performance for general-purpose applications
  - Simpler mental model for developers
- **Cons**: 
  - Smaller ecosystem compared to Tokio
  - Less optimization for high-performance networking
  - Fewer protocol implementations available
- **Rejection Reason**: Smaller ecosystem and less networking-focused optimization

### Alternative 2: smol
- **Description**: Lightweight async runtime
- **Pros**:
  - Very small runtime overhead
  - Simple and minimal design
  - Good for embedded or resource-constrained environments
- **Cons**:
  - Much smaller ecosystem
  - Less battle-tested for high-performance scenarios
  - Limited networking protocol support
- **Rejection Reason**: Limited ecosystem and lack of high-performance networking libraries

### Alternative 3: Custom Runtime
- **Description**: Build a custom async runtime tailored to proxy needs
- **Pros**:
  - Maximum optimization for specific use case
  - Complete control over scheduling and I/O
  - No unnecessary features or overhead
- **Cons**:
  - Significant development and maintenance effort
  - High complexity and potential for bugs
  - Miss out on community optimizations and features
- **Rejection Reason**: Development cost and risk outweigh benefits

## Consequences

### Positive
- **Mature Ecosystem**: Rich ecosystem with hyper, tonic, tower, and other networking libraries
- **High Performance**: Optimized for high-throughput, low-latency networking applications
- **Protocol Support**: Excellent support for HTTP/2, WebSocket, gRPC out of the box
- **Community Support**: Large, active community with extensive documentation
- **Production Ready**: Battle-tested in high-performance production systems
- **Tooling**: Good debugging and profiling tools available
- **Memory Efficiency**: Efficient memory usage with zero-copy optimizations where possible

### Negative  
- **Complexity**: More complex than simpler runtimes, especially for debugging
- **Binary Size**: Larger binary size due to comprehensive feature set
- **Learning Curve**: Requires understanding of Tokio-specific concepts and patterns
- **Dependency Weight**: Pulls in more dependencies than minimal alternatives

### Neutral
- **API Stability**: Well-established APIs that are unlikely to change dramatically
- **Documentation**: Extensive documentation but can be overwhelming for newcomers
- **Configuration Options**: Many configuration options requiring careful tuning

## Implementation Notes

### Runtime Configuration
```rust
tokio::runtime::Builder::new_multi_threaded()
    .worker_threads(num_cpus::get())
    .enable_all()
    .build()
    .unwrap()
```

### Key Integration Points
- **HTTP Server**: Use `hyper` with Tokio for HTTP/1.1 and HTTP/2 support
- **WebSocket**: Use `tokio-tungstenite` for WebSocket protocol support
- **gRPC**: Use `tonic` for xDS and other gRPC communication
- **TLS**: Use `tokio-rustls` for TLS termination and client connections
- **Timers**: Use `tokio::time` for request timeouts and retry logic

### Performance Considerations
- **Thread Pool Sizing**: Configure worker threads based on workload characteristics
- **Task Spawning**: Minimize task spawning overhead in hot paths
- **Blocking Operations**: Use `spawn_blocking` for CPU-intensive operations
- **Memory Pools**: Leverage connection and buffer pooling where applicable

### Error Handling
- **Runtime Panics**: Implement panic hooks for graceful runtime failure handling
- **Task Failures**: Proper error propagation and task supervision
- **Resource Cleanup**: Ensure proper cleanup of resources on task cancellation

## Acceptance Criteria

- [x] Tokio runtime successfully integrated into core proxy
- [x] Multi-threaded runtime configured appropriately
- [x] HTTP/2 and WebSocket support working via Tokio ecosystem
- [x] Performance benchmarks meet latency and throughput requirements
- [x] Proper error handling and resource cleanup implemented
- [x] Thread pool configuration optimized for target workloads

## References

- [Tokio documentation](https://tokio.rs/)
- [Tokio performance guide](https://tokio.rs/tokio/topics/performance)
- [Hyper HTTP library](https://hyper.rs/)
- [Tonic gRPC library](https://github.com/hyperium/tonic)
- [tokio-rustls TLS integration](https://github.com/tokio-rs/tls)

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2024-10-15 | Architecture Team | Initial decision |