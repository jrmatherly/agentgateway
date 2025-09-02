# AGENTS.md

Guidelines for AI agents working on the agentgateway project.

## Development Workflow

**Frontend Development**:
- Always build the UI first: `cd ui && npm install && npm run build && cd ..`
- Use `cd ui && npm run dev` for iterative frontend development
- Do *not* run `npm run build` inside the UI directory during agent sessions - use `npm run dev`

**Backend Development**:
- Use `cargo build` for development iterations
- Use `make build` only when you need the full release build with UI features
- Do *not* run `make build` repeatedly during development - it's slow and includes release optimizations

**Testing**:
- Always run `make test` before proposing changes
- For specific crate testing: `cargo test -p <crate-name>`
- Run `make lint` before any commits - the CI will fail without proper formatting

## Build Dependencies

**Critical**: The frontend must be built before the Rust backend can compile with UI features:

```bash
# Correct order - always do this first
cd ui && npm install && npm run build && cd ..
# Then build Rust
make build
```

**Never** try to build the Rust backend with UI features before building the frontend - it will fail.

## Code Organization

**Rust Crates**:
- New protocol implementations go in `crates/agentgateway/src/`
- Shared utilities belong in `crates/core/src/`
- The main binary is in `crates/agentgateway-app/src/main.rs`

**Configuration**:
- All config changes require schema regeneration: `make generate-schema`
- Test configs in `examples/` directory - start with `basic/` for simple changes
- Validate configs with: `./target/release/agentgateway -f <config.yaml> --validate-only`

**Frontend**:
- Prefer TypeScript (.tsx/.ts) for all new components
- Use Radix UI components when possible
- Follow Tailwind v4 conventions for styling

## Common Pitfalls

**Multi-language Build Issues**:
- Don't modify Rust code and frontend simultaneously without rebuilding frontend first
- Schema changes require `make generate-schema` - don't skip this step
- Protocol buffer changes need `make generate-apis`

**Testing Issues**:
- Some tests require validation dependencies: `make run-validation-deps` first
- Stop validation deps when done: `make stop-validation-deps`
- Windows CI excludes MCP authentication tests - don't rely on them for Windows compatibility

**Configuration Issues**:
- YAML configs use JSON schema validation - check `schema/local.json`
- Config validation happens at runtime - always test with `--validate-only`
- Multi-tenant configs need careful namespace separation

## Useful Commands

| Command | Purpose |
|---------|---------|
| `make build` | Full release build with UI (slow, use sparingly) |
| `cargo build` | Fast development build without UI |
| `make test` | Run all tests |
| `make lint` | Format and clippy check (required before commits) |
| `make fix-lint` | Auto-fix formatting and clippy issues |
| `make gen` | Generate APIs and schema (after protocol/config changes) |
| `cd ui && npm run dev` | Start frontend development server |
| `make run-validation-deps` | Start test dependencies |
| `./target/release/agentgateway -f <config>` | Run with specific config |

## Development Environment

- Rust 1.89+ required (uses 2024 edition)
- Node.js with npm 10+ for frontend
- Go 1.24+ for protocol generation
- The project uses workspace-level dependencies - don't modify individual Cargo.toml files unless adding new dependencies

## Protocol Development

When adding new protocol support:
1. Define protocol structs in appropriate `crates/agentgateway/src/` module
2. Update routing in main application logic
3. Add configuration schema updates
4. Run `make generate-schema` to update JSON schema
5. Create example config in `examples/` directory
6. Test with validation: `make validate`

## Performance Considerations

- Use `jemalloc` feature for production builds: `cargo build --features jemalloc`
- Frontend uses Turbopack for fast development builds
- The project supports CPU affinity and async compression - don't disable these optimizations
- Protocol implementations use zero-copy where possible - maintain this pattern