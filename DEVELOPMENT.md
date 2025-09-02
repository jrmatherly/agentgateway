# Local Development

This document provides instructions for setting up and running the Agentgateway project locally using different development approaches.

## Prerequisites

Choose your development approach based on your preferences and requirements:

### Option 1: Native Development
- Rust 1.86+
- npm 10+
- PostgreSQL 17+ (for database features)
- Redis 8+ (for caching features)

### Option 2: Docker Development (Recommended)
- Docker 20.10+
- Docker Compose 2.0+

### Option 3: Hybrid Development
- Docker 20.10+ and Docker Compose 2.0+ (for services)
- Rust 1.86+ and npm 10+ (for local builds)

## Development Approaches

### 🐳 Docker Development (Recommended)

The easiest way to get started with full service dependencies.

#### Service Architecture

Agentgateway uses multiple Docker Compose files for different environments:

- **docker-compose.yml**: Core services (agentgateway, postgres, redis, observability stack)
- **docker-compose.dev.yml**: Development-specific services (mcp-mock, dev-tools, debug configurations)
- **docker-compose.override.yml**: Local overrides (automatically loaded)

**Service Distribution:**
```yaml
Core Services (docker-compose.yml):
  - agentgateway: Main application
  - postgres: Database
  - redis: Caching
  - prometheus, grafana, jaeger: Observability
  - ui-dev: UI development server (dev profile only)

Development Services (docker-compose.dev.yml):
  - mcp-mock: MCP protocol testing server
  - dev-tools: Development utilities container
  - Enhanced agentgateway: Debug settings, additional ports
```

#### Quick Start
```bash
# Copy and customize environment variables
cp .env.example .env

# Start all services with development configuration
docker compose up -d

# View logs
docker compose logs -f agentgateway

# Stop all services
docker compose down
```

#### Development with UI Hot Reload
```bash
# Start complete development environment with UI hot reload and dev tools
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d

# UI development server available at http://localhost:15000
# Main application available at http://localhost:3000
# Agentgateway UI available at http://localhost:3000/ui
```

#### Available Services

**Core Application Services:**
- **Agentgateway**: http://localhost:3000 (main app) & http://localhost:8080 (metrics)
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

**Development Services (with dev profile/files):**
- **UI Development**: http://localhost:15000 (hot reload) *[dev profile required]*
- **MCP Mock Server**: http://localhost:3001 (MCP protocol testing) *[docker-compose.dev.yml]*
- **Dev Tools**: Container utilities *[docker-compose.dev.yml]*

**Observability Stack:**
- **Prometheus**: http://localhost:9090 (metrics collection)
- **Grafana**: http://localhost:3003 (dashboards - admin/admin) 
- **Jaeger**: http://localhost:16686 (UI), localhost:4317 (OTLP gRPC), localhost:4318 (OTLP HTTP)
- **OTEL Collector**: http://localhost:8889 (metrics endpoint)

**Service Activation:**
```bash
# All core services
docker compose up -d

# Core + UI hot reload  
docker compose --profile dev up -d

# Core + development tools (no UI hot reload)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Complete development environment (recommended)
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d
```

#### Development Commands
```bash
# Rebuild specific service
docker compose build agentgateway

# Complete development environment (recommended)
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d

# Development services only (without UI hot reload)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Basic services with UI hot reload (without dev tools)
docker compose --profile dev up -d

# Check service health
docker compose ps

# Verify complete development stack
docker compose -f docker-compose.yml -f docker-compose.dev.yml config --services

# Expected services for complete dev environment:
# agentgateway, postgres, redis, ui-dev, mcp-mock, dev-tools, 
# prometheus, grafana, jaeger, otel-collector
```

#### Verifying Development Environment

```bash
# Check if all expected services are running
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev ps

# Test service connectivity
curl http://localhost:3000/health || echo "Agentgateway not ready"
curl http://localhost:15000 || echo "UI dev server not ready"  
curl http://localhost:3001 || echo "MCP mock server not ready"
curl http://localhost:3003 || echo "Grafana not ready"
curl http://localhost:9090/-/ready || echo "Prometheus not ready"

# View logs for troubleshooting
docker compose logs -f agentgateway
docker compose logs -f ui-dev
docker compose logs -f mcp-mock
```

### 🔧 Native Development

Build and run directly on your system without containers.

#### Build the UI
```bash
cd ui
npm install
npm run build
cd ..
```

#### Build the Binary
```bash
# Set Git fetch method for corporate networks
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# Build with UI feature enabled
make build
```

#### Run the Application
```bash
# Run with default configuration
./target/release/agentgateway

# Run with custom configuration
./target/release/agentgateway -f examples/basic/config.yaml

# Validate configuration only
./target/release/agentgateway -f examples/basic/config.yaml --validate-only
```

#### Access the UI
Open your browser and navigate to `http://localhost:3000/ui` to see the agentgateway UI.

### 🔄 Hybrid Development

Use Docker for services but develop agentgateway natively.

#### Start Supporting Services
```bash
# Start only the supporting services (postgres, redis, monitoring)
docker compose up -d postgres redis prometheus grafana jaeger otel-collector

# Build and run agentgateway natively
make build
./target/release/agentgateway -f examples/basic/config.yaml
```

## Development Workflows

### Making Changes

#### Code Changes
1. Make your changes to Rust or TypeScript code
2. For Rust changes: `cargo build` or use Docker rebuild
3. For UI changes: `cd ui && npm run build` or use ui-dev service
4. Test your changes

#### Configuration Changes
1. Update configuration files in `examples/` directory
2. Restart agentgateway to pick up changes
3. Or use `--validate-only` flag to test configuration

#### Docker Configuration Changes
1. Edit `docker-compose.yml` or override files
2. Run `docker compose up -d` to apply changes
3. Use `docker compose build` to rebuild images if needed

### Testing

#### Unit Tests
```bash
# Native testing
make test

# Docker testing
docker compose exec agentgateway cargo test
```

#### Integration Testing
```bash
# Start validation dependencies
make run-validation-deps

# Run tests
make test

# Stop validation dependencies
make stop-validation-deps
```

#### Linting and Formatting
```bash
# Native linting
make lint
make fix-lint

# Frontend linting
cd ui && npm run lint
```

## Environment Configuration

### Environment Variables
Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

Key development variables:
- `RUST_LOG=info` - Logging level
- `POSTGRES_PASSWORD` - Database password
- `REDIS_PASSWORD` - Cache password
- `GF_SECURITY_ADMIN_PASSWORD` - Grafana admin password

### Configuration Files
- `examples/basic/config.yaml` - Basic setup
- `examples/multiplex/config.yaml` - Multiple targets
- `examples/authorization/config.yaml` - JWT authentication
- `examples/tls/config.yaml` - TLS configuration

## Troubleshooting

### Common Issues

#### Port Conflicts
```bash
# Check what's using ports
lsof -i :3000 -i :3001 -i :5432 -i :6379 -i :9090

# Stop conflicting services
docker compose down
```

#### Permission Issues
```bash
# Fix volume permissions for Docker
sudo chown -R $USER:$USER ./data/
```

#### Docker Build Issues
```bash
# Clean Docker cache
docker system prune -f

# Rebuild without cache
docker compose build --no-cache agentgateway
```

#### Build Hangs at "Resolving Provenance for Metadata File"
This is a known Docker BuildKit issue with provenance attestations:

```bash
# Solution 1: Use environment variable (recommended for development)
export BUILDX_NO_DEFAULT_ATTESTATIONS=1
docker compose --profile dev up -d

# Solution 2: Set in .env file (copy from .env.example)
cp .env.example .env
# Edit .env and ensure BUILDX_NO_DEFAULT_ATTESTATIONS=1 is set

# Solution 3: Build with explicit flag
docker buildx build --provenance=false -t agentgateway .
```

**Why this happens**: BuildKit v0.11+ enables provenance attestations by default, which can cause builds to hang for 7+ minutes on complex multi-stage builds. This is safe to disable for development environments.

#### OTEL Collector Fails with "unknown type: jaeger"
This occurs with OpenTelemetry Collector v0.94+ which removed the legacy Jaeger exporter:

```bash
# Error message
Error: failed to get config: cannot unmarshal the configuration: 1 error(s) decoding:
* error decoding 'exporters': unknown type: "jaeger" for id: "jaeger"

# Solution: Configuration has been updated to use OTLP
# The otel-collector-config.yaml now uses otlp/jaeger exporter
# Jaeger receives traces via OTLP on ports 4317/4318
# No action needed - this is already fixed in the configuration
```

**Why this happens**: OpenTelemetry moved away from legacy protocol exporters. Jaeger now supports OTLP natively, providing better standardization and performance.

#### Port Conflict Errors
```bash
# Error: "Bind for 0.0.0.0:4317 failed: port is already allocated"
# This typically happens when multiple services try to use the same port

# Stop all containers to clear port conflicts
docker compose down

# Check what's using a specific port
lsof -i :4317

# Restart with clean state
docker compose --profile dev up -d
```

#### Service Won't Start
```bash
# Check specific service logs
docker compose logs agentgateway

# For development environment with all files
docker compose -f docker-compose.yml -f docker-compose.dev.yml logs agentgateway

# Restart specific service
docker compose restart agentgateway

# Check service health
docker compose ps

# Verify which services should be running
docker compose -f docker-compose.yml -f docker-compose.dev.yml config --services
```

#### Port Conflict Errors
```bash
# Error: "Bind for 0.0.0.0:3001 failed: port is already allocated"
# This happens when multiple services try to use the same port

# Check what's using the conflicting port
sudo lsof -i :3001
docker ps --filter "publish=3001"

# Stop all containers to clear port conflicts
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev down

# Wait for complete cleanup and restart
sleep 3
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d
```

#### Missing Development Services
```bash
# Problem: UI hot reload not available (port 15000)
# Solution: Ensure dev profile is activated
docker compose --profile dev up -d

# Problem: MCP mock server not available (port 3001) 
# Solution: Include docker-compose.dev.yml
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Problem: Missing both UI hot reload AND development tools
# Solution: Use complete development command
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d
```

#### UI Build Issues
```bash
# Clean node modules and rebuild
cd ui
rm -rf node_modules package-lock.json
npm install
npm run build
cd ..
```

### Development Tips

1. **Use Docker for consistency** - Ensures same environment across team
2. **Check logs frequently** - `docker compose logs -f agentgateway`
3. **Use configuration validation** - `--validate-only` flag
4. **Monitor resource usage** - Check Grafana dashboards
5. **Complete development environment** - Always use `docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d`

#### Recommended Makefile Addition

Consider adding this target to your Makefile for easier development:

```makefile
.PHONY: dev
dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d

.PHONY: dev-down  
dev-down:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev down

.PHONY: dev-logs
dev-logs:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f agentgateway ui-dev mcp-mock
```

Then use: `make dev`, `make dev-down`, `make dev-logs`
