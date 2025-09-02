# Agentgateway Quick Start Guide

Get up and running with Agentgateway in under 10 minutes.

## Prerequisites

Before you start, make sure you have:

- **Rust 1.89+** - Install via [rustup](https://rustup.rs/)
- **Node.js 23+** with npm 10+
- **Git** for cloning the repository

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/agentgateway/agentgateway.git
cd agentgateway
```

### 2. Build the UI

```bash
cd ui
npm install
npm run build
cd ..
```

### 3. Build Agentgateway

```bash
# Set Git CLI flag for Cargo (required for some dependencies)
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# Build the release binary
make build
```

### 4. Run Agentgateway

```bash
# Run with default configuration (empty config)
./target/release/agentgateway

# Or run with a specific example
./target/release/agentgateway -f examples/basic/config.yaml
```

### 5. Access the UI

Open your browser and navigate to:
```
http://localhost:15000/ui
```

## Quick Test

To verify everything is working, try the basic example:

```bash
# Run the basic MCP example
./target/release/agentgateway -f examples/basic/config.yaml
```

This will:
- Start a proxy on port 3000
- Expose an MCP server via stdio
- Serve the UI on port 15000

## Development Commands

```bash
# Run tests
make test

# Run validation tests  
make validate

# Format and fix linting
make fix-lint

# Clean build artifacts
make clean

# Validate configuration only
./target/release/agentgateway -f examples/basic/config.yaml --validate-only
```

## Configuration Validation

Before running, you can validate your configuration:

```bash
# Validate a configuration file
./target/release/agentgateway -f path/to/config.yaml --validate-only
```

## Troubleshooting

### Build Issues

**Problem**: Cargo build fails with git dependencies
```bash
# Solution: Enable Git CLI for Cargo
export CARGO_NET_GIT_FETCH_WITH_CLI=true
make build
```

**Problem**: UI build fails
```bash
# Solution: Check Node.js version (requires 23+)
node --version
# Update Node.js if needed, then:
cd ui && npm install && npm run build
```

### Runtime Issues

**Problem**: Port 15000 already in use
```bash
# Solution: Check what's using the port
lsof -i :15000
# Kill the process or change the port in configuration
```

**Problem**: Permission denied accessing UI
```bash
# Solution: Make sure UI was built successfully
ls -la ui/.next/
# Rebuild if necessary
cd ui && npm run build
```

### Configuration Issues

**Problem**: Invalid configuration
```bash
# Solution: Validate configuration first
./target/release/agentgateway -f config.yaml --validate-only
# Check against schema in schema/local.json
```

## Next Steps

1. **Explore Examples**: Check out different configurations in `examples/`
2. **Read Documentation**: Full docs at [agentgateway.dev/docs](https://agentgateway.dev/docs/)
3. **Join Community**: [Discord server](https://discord.gg/BdJpzaPjHv)
4. **Contribute**: See [CONTRIBUTION.md](CONTRIBUTION.md) for guidelines

## Quick Reference

| Command | Description |
|---------|-------------|
| `make build` | Build release binary |
| `make test` | Run all tests |
| `make validate` | Validate example configurations |
| `make lint` | Check code formatting |
| `make clean` | Clean build artifacts |
| `./target/release/agentgateway -h` | Show CLI help |
| `./target/release/agentgateway -V` | Show version |

For detailed information, see [ONBOARDING.md](ONBOARDING.md).