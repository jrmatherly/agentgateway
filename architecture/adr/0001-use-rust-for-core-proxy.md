# 0001. Use Rust for Core Proxy Implementation

Date: 2024-10-01

## Status

✅ Accepted

## Context

Agentgateway needs to be a high-performance data plane capable of handling thousands of concurrent connections with sub-millisecond latency for AI agent communication. The core requirements include:

- **High Performance**: Handle thousands of concurrent connections with minimal latency
- **Memory Safety**: Prevent memory leaks and security vulnerabilities
- **Concurrent Safety**: Safe handling of shared state across threads
- **Systems Programming**: Low-level control over network protocols and resources
- **Ecosystem**: Rich ecosystem for networking, async I/O, and protocol implementations

The proxy is the most performance-critical component and needs to be highly optimized.

## Decision

We will implement the core proxy engine in Rust with the following specific choices:

- **Language**: Rust 1.89+ for the entire backend/proxy implementation
- **Runtime**: Tokio async runtime for high-performance async I/O
- **Memory Management**: Leveraging Rust's ownership system for zero-cost memory safety
- **Concurrency**: Using Rust's type system to ensure thread safety
- **FFI**: Rust can interface with C libraries when needed for specialized functionality

## Alternatives Considered

### Alternative 1: Go
- **Description**: Implement the proxy in Go with goroutines and channels
- **Pros**: 
  - Excellent built-in concurrency primitives
  - Fast compilation times
  - Large ecosystem for networking and web services
  - Garbage collector handles memory management
- **Cons**: 
  - Garbage collector pauses can affect tail latencies
  - Higher memory overhead due to GC
  - Less control over memory layout and allocation
- **Rejection Reason**: GC pauses are unacceptable for sub-millisecond latency requirements

### Alternative 2: C++
- **Description**: Implement using modern C++17/20 with libraries like Boost.Asio
- **Pros**:
  - Maximum performance and control
  - Zero-cost abstractions
  - Mature ecosystem for high-performance networking
- **Cons**:
  - Memory safety vulnerabilities (buffer overflows, use-after-free)
  - Complex memory management requiring extensive testing
  - Longer development time and higher maintenance burden
- **Rejection Reason**: Memory safety risks are unacceptable for a security-focused proxy

### Alternative 3: Node.js/TypeScript
- **Description**: Use Node.js event loop for async I/O handling
- **Pros**:
  - JavaScript ecosystem familiarity
  - Good async I/O performance
  - Fast prototyping and development
- **Cons**:
  - Single-threaded event loop limits CPU utilization
  - V8 garbage collection pauses
  - Limited control over low-level optimizations
- **Rejection Reason**: Performance limitations and lack of true parallelism

## Consequences

### Positive
- **Zero-cost abstractions**: High-level code with C-like performance
- **Memory safety**: Eliminates entire classes of security vulnerabilities
- **Concurrent safety**: Type system prevents data races and deadlocks
- **Performance**: Predictable performance without GC pauses
- **Ecosystem**: Rich networking ecosystem (hyper, tokio, etc.)
- **Binary size**: Small, self-contained binaries
- **Resource usage**: Low memory footprint and CPU efficiency

### Negative  
- **Learning curve**: Team needs to learn Rust ownership and borrowing concepts
- **Compilation time**: Slower compilation compared to interpreted languages
- **Development velocity**: Initially slower development due to strict compiler
- **Debugging complexity**: Async debugging can be more challenging
- **Library maturity**: Some libraries may be less mature than alternatives

### Neutral
- **Type system**: Strong type system requires more upfront design but catches errors early
- **Cargo ecosystem**: Different package management approach than other languages
- **Community**: Smaller but highly engaged community compared to more established languages

## Implementation Notes

- **Rust Version**: Use Rust 1.89+ as specified in `rust-toolchain.toml`
- **Async Runtime**: Tokio for all async operations with careful consideration of runtime configuration
- **Error Handling**: Use `anyhow` for error propagation and `thiserror` for custom error types
- **Memory Management**: Leverage `Arc<RwLock<T>>` for shared state and `Arc<T>` for immutable shared data
- **Performance Profiling**: Regular profiling with tools like `perf`, `flamegraph`, and `criterion`
- **Testing**: Comprehensive unit and integration testing with property-based testing where appropriate

## Acceptance Criteria

- [x] Core proxy implemented in Rust
- [x] Tokio async runtime integrated
- [x] Sub-millisecond request routing latency achieved
- [x] Memory safety validated through testing
- [x] Concurrent safety verified
- [x] Performance benchmarks established

## References

- [Tokio async runtime](https://tokio.rs/)
- [Rust performance book](https://nnethercote.github.io/perf-book/)
- [Hyper HTTP library](https://hyper.rs/)
- [Rust memory safety guarantees](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2024-10-01 | Architecture Team | Initial decision |