# Agentgateway Containerization Guide

This document outlines the production-ready containerization strategy for Agentgateway, including Docker, Docker Compose, and Kubernetes deployment configurations.

## Overview

Agentgateway uses a multi-stage Docker build optimized for security, performance, and operational excellence. The containerization strategy includes:

- **Security-hardened Dockerfile** with distroless runtime images
- **Multi-architecture support** (amd64, arm64)
- **Comprehensive monitoring** with OpenTelemetry, Prometheus, and Grafana
- **Kubernetes-ready manifests** with security best practices
- **Development workflow** with Docker Compose

## Architecture Components

### Core Services
- **Agentgateway**: Main application (Rust-based)
- **UI Development**: Next.js frontend (development mode)
- **OpenTelemetry Collector**: Telemetry data collection and processing
- **Prometheus**: Metrics storage and querying
- **Grafana**: Metrics visualization and dashboards
- **Jaeger**: Distributed tracing
- **Redis**: Caching and rate limiting
- **PostgreSQL**: Database (if required)

## Container Images

### Production Image
- **Base**: `gcr.io/distroless/cc-debian12` (minimal, secure runtime)
- **User**: Non-root (UID 65532)
- **Security**: Read-only filesystem, no privileges, minimal attack surface
- **Health checks**: Built-in application validation
- **Size**: ~50MB (optimized with multi-stage builds)

### Development Image
- **Base**: `rust:1.89.0-slim-bookworm` (with development tools)
- **Features**: Debug symbols, development dependencies
- **Volumes**: Source code mounting for faster iteration

## Security Features

### Container Security
✅ **Non-root user** (UID 65532)  
✅ **Read-only root filesystem**  
✅ **No privileged escalation**  
✅ **Minimal base image** (distroless)  
✅ **Security labels and metadata**  
✅ **Capability dropping** (all capabilities removed)  
✅ **Seccomp profile** (runtime default)  

### Network Security
✅ **Network policies** for pod-to-pod communication  
✅ **Ingress security headers**  
✅ **TLS termination** with cert-manager  
✅ **Rate limiting** at ingress and application level  
✅ **CORS configuration** for API access  

## Quick Start

### Development with Docker Compose

```bash
# Start all services
docker-compose up -d

# Start with development profile
docker-compose --profile dev up -d

# View logs
docker-compose logs -f agentgateway

# Stop all services
docker-compose down

# Clean up volumes
docker-compose down -v
```

### Production Build

```bash
# Build production image
make docker

# Build with specific architecture
docker build --platform linux/amd64 -t agentgateway:latest .

# Build with version tagging
docker build \
  --build-arg VERSION=$(git describe --tags --always) \
  --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --build-arg VCS_REF=$(git rev-parse HEAD) \
  -t agentgateway:latest .
```

### Kubernetes Deployment

```bash
# Create namespace and apply all manifests
kubectl apply -f manifests/k8s-namespace.yaml
kubectl apply -f manifests/k8s-rbac.yaml
kubectl apply -f manifests/k8s-configmap.yaml
kubectl apply -f manifests/k8s-deployment.yaml
kubectl apply -f manifests/k8s-service.yaml
kubectl apply -f manifests/k8s-ingress.yaml
kubectl apply -f manifests/k8s-hpa.yaml
kubectl apply -f manifests/k8s-monitoring.yaml

# Verify deployment
kubectl get pods -n agentgateway
kubectl get svc -n agentgateway
kubectl logs -f deployment/agentgateway -n agentgateway
```

## Configuration Management

### Environment Variables

Agentgateway supports **60+ environment variables** for comprehensive configuration without code changes:

#### Core Application Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `RUST_LOG` | `info` | Log level (error/warn/info/debug/trace) |
| `RUST_BACKTRACE` | `0` | Enable panic backtraces (0=off, 1=on) |
| `IPV6_ENABLED` | `true` | Enable IPv6 network support |
| `ADMIN_ADDR` | `localhost:15000` | Admin interface binding address |
| `STATS_ADDR` | `0.0.0.0:15020` | Metrics endpoint binding address |
| `READINESS_ADDR` | `0.0.0.0:15021` | Health check endpoint binding |

#### Performance & Threading  

| Variable | Default | Description |
|----------|---------|-------------|
| `WORKER_THREADS` | CPU count | Thread count: number (4) or percentage (75%) |
| `CPU_LIMIT` | auto-detect | Override CPU count (Kubernetes downward API) |
| `THREADING_MODE` | `default` | Threading model: default/thread_per_core |

#### HTTP/2 Protocol Optimization

| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP2_STREAM_WINDOW_SIZE` | `4194304` | Per-stream window size (4MB) |
| `HTTP2_CONNECTION_WINDOW_SIZE` | `16777216` | Per-connection window (16MB) |
| `HTTP2_FRAME_SIZE` | `1048576` | HTTP/2 frame size (1MB) |
| `POOL_MAX_STREAMS_PER_CONNECTION` | `100` | Max streams per connection |
| `POOL_UNUSED_RELEASE_TIMEOUT` | `300s` | Connection pool timeout |

#### Connection Management

| Variable | Default | Description |
|----------|---------|-------------|
| `CONNECTION_MIN_TERMINATION_DEADLINE` | `5s` | Min graceful shutdown time |
| `CONNECTION_TERMINATION_DEADLINE` | `30s` | Max termination time |
| `TERMINATION_GRACE_PERIOD_SECONDS` | `30` | Kubernetes grace period |
| `NETWORK` | - | Service mesh network identifier |

#### xDS Dynamic Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `XDS_ADDRESS` | - | xDS server URL for dynamic config |
| `LOCAL_XDS_PATH` | - | Local config file path (alternative) |
| `NAMESPACE` | - | Service mesh namespace |
| `GATEWAY` | - | Gateway instance name |

#### Certificate Authority & Security  

| Variable | Default | Description |
|----------|---------|-------------|
| `CA_ADDRESS` | - | Certificate Authority server URL |
| `TRUST_DOMAIN` | `cluster.local` | Service mesh trust domain |
| `SERVICE_ACCOUNT` | - | Kubernetes service account |
| `CLUSTER_ID` | `Kubernetes` | Cluster identifier |
| `AUTH_TOKEN` | - | Authentication token path/value |
| `CA_ROOT_CA` | istio cert path | Root CA certificate path |

#### Observability & Telemetry

| Variable | Default | Description |
|----------|---------|-------------|
| `OTLP_ENDPOINT` | - | OpenTelemetry collector endpoint |
| `OTLP_PROTOCOL` | `grpc` | OTLP protocol (grpc/http) |
| `OTLP_HEADERS` | - | Custom headers: JSON or CSV format |
| `PROMETHEUS_ENDPOINT` | `0.0.0.0:8080` | Prometheus metrics endpoint |

#### Kubernetes Metadata (Auto-injected)

| Variable | Default | Description |
|----------|---------|-------------|
| `INSTANCE_IP` | `1.1.1.1` | Pod IP address |
| `POD_NAME` | - | Kubernetes pod name |
| `POD_NAMESPACE` | - | Kubernetes pod namespace |
| `NODE_NAME` | - | Kubernetes node name |
| `K8S_NAMESPACE` | - | Alternative namespace variable |
| `K8S_POD_NAME` | - | Alternative pod name variable |
| `K8S_NODE_NAME` | - | Alternative node name variable |

#### Environment-Specific Configurations

**Development (.env.example):**
```bash
RUST_LOG=debug
RUST_BACKTRACE=1
WORKER_THREADS=4
OTLP_HEADERS={"service":"agentgateway-dev","environment":"development"}
```

**Production (docker-compose.prod.yml):**
```bash
RUST_LOG=warn
WORKER_THREADS=100%
THREADING_MODE=thread_per_core
HTTP2_STREAM_WINDOW_SIZE=16777216
POOL_MAX_STREAMS_PER_CONNECTION=500
```

### Configuration Files

- **Application Config**: `/etc/agentgateway/config.yaml` (mounted from ConfigMap)
- **OpenTelemetry**: `/etc/otelcol-contrib/config.yaml`
- **Prometheus**: `/etc/prometheus/prometheus.yml`

## Monitoring and Observability

### Metrics Collection
- **Application Metrics**: Exposed on port 8080 (`/metrics`)
- **OpenTelemetry**: OTLP gRPC (4317) and HTTP (4318)
- **Prometheus**: Scrapes metrics every 30s
- **Custom Metrics**: Request rates, latency percentiles, error rates

### Health Checks
- **Liveness Probe**: `/health` endpoint (30s interval)
- **Readiness Probe**: `/ready` endpoint (5s interval)
- **Startup Probe**: 30s grace period for initialization

### Alerting Rules
- **Service Down**: Instance unavailable > 1 minute
- **High Error Rate**: 5xx errors > 10% for 5 minutes
- **High Latency**: 95th percentile > 1 second for 5 minutes
- **Resource Usage**: CPU > 80% or Memory > 85% for 10 minutes

### Dashboards
- **Grafana**: Pre-configured dashboards for application metrics
- **Jaeger UI**: Distributed tracing visualization
- **Prometheus**: Raw metrics and alerting rules

## Scaling and Performance

### Horizontal Pod Autoscaling
- **Min Replicas**: 3 (high availability)
- **Max Replicas**: 50 (scale to demand)
- **CPU Target**: 70% utilization
- **Memory Target**: 80% utilization
- **Custom Metrics**: HTTP requests per second

### Resource Limits
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Pod Disruption Budget
- **Min Available**: 2 pods (ensures availability during updates)
- **Rolling Update**: Max 1 unavailable, max 1 surge

## Security Scanning and Compliance

### Container Scanning
```bash
# Scan image for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image agentgateway:latest

# Scan filesystem
docker run --rm -v $(pwd):/workspace aquasec/trivy fs /workspace
```

### Security Policies
- **Pod Security Standards**: Restricted profile enforced
- **Network Policies**: Ingress/egress traffic controlled
- **RBAC**: Minimal permissions principle
- **Secrets Management**: External secret store integration

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Build and Deploy
on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: |
          ghcr.io/agentgateway/agentgateway:latest
          ghcr.io/agentgateway/agentgateway:${{ github.sha }}
        build-args: |
          VERSION=${{ github.ref_name }}
          BUILD_DATE=${{ steps.date.outputs.date }}
          VCS_REF=${{ github.sha }}
```

## Development Workflow

### Local Development
```bash
# Start development environment
docker-compose --profile dev up -d

# Watch logs
docker-compose logs -f agentgateway ui-dev

# Execute commands in container
docker-compose exec agentgateway /bin/bash
docker-compose exec dev-tools cargo test

# Rebuild after changes
docker-compose build agentgateway
docker-compose restart agentgateway
```

### Testing
```bash
# Run unit tests in container
docker-compose exec dev-tools cargo test

# Integration tests with validation dependencies
make run-validation-deps
docker-compose exec agentgateway cargo test --features integration
make stop-validation-deps

# Load testing
docker-compose exec dev-tools cargo install wrk
docker-compose exec dev-tools wrk -t12 -c400 -d30s http://agentgateway:3000/
```

## Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
docker-compose logs agentgateway

# Check configuration
docker-compose exec agentgateway /app/agentgateway --validate-only -f /app/config.yaml

# Check file permissions
docker-compose exec agentgateway ls -la /app/
```

#### High Resource Usage
```bash
# Check resource usage
kubectl top pods -n agentgateway

# Check metrics
curl http://localhost:8080/metrics

# Check HPA status
kubectl get hpa -n agentgateway
```

#### Network Connectivity Issues
```bash
# Test service connectivity
kubectl exec -it deployment/agentgateway -n agentgateway -- curl localhost:3000/health

# Check network policies
kubectl describe networkpolicy -n agentgateway

# Check ingress
kubectl describe ingress -n agentgateway
```

### Debugging Commands

```bash
# Enter running container
kubectl exec -it deployment/agentgateway -n agentgateway -- /bin/sh

# Check application logs
kubectl logs -f deployment/agentgateway -n agentgateway

# Port forward for local access
kubectl port-forward svc/agentgateway 3000:3000 -n agentgateway

# Check events
kubectl get events -n agentgateway --sort-by='.lastTimestamp'
```

## Performance Optimization

### Build Optimization
- **Multi-stage builds**: Separate build and runtime stages
- **Layer caching**: Optimize Dockerfile layer ordering
- **Dependency caching**: Cache Cargo registry and npm packages
- **Binary optimization**: Release profile with LTO and optimizations

### Runtime Optimization
- **Memory settings**: Appropriate resource limits and requests
- **CPU affinity**: Node selector for performance-critical workloads
- **Storage**: Use persistent volumes for data that needs persistence
- **Network**: Service mesh for advanced traffic management

## Security Hardening Checklist

### Container Level
- [x] Non-root user execution
- [x] Read-only root filesystem  
- [x] No privileged escalation
- [x] Minimal base image
- [x] Regular security updates
- [x] Vulnerability scanning

### Kubernetes Level
- [x] RBAC with minimal permissions
- [x] Network policies
- [x] Pod security standards
- [x] Resource quotas
- [x] Secrets management
- [x] Security contexts

### Infrastructure Level
- [x] TLS everywhere
- [x] Certificate management
- [x] Ingress security headers
- [x] Rate limiting
- [x] Monitoring and alerting
- [x] Backup and disaster recovery

## Maintenance and Updates

### Regular Tasks
- **Image Updates**: Monthly base image updates
- **Security Patches**: Weekly security scanning
- **Configuration Review**: Quarterly configuration audit
- **Performance Review**: Monthly performance analysis
- **Backup Verification**: Weekly backup testing

### Update Procedures
1. **Build new image** with updated dependencies
2. **Security scan** the new image
3. **Deploy to staging** environment
4. **Run integration tests**
5. **Rolling update** to production
6. **Monitor** deployment metrics
7. **Rollback** if issues detected

This containerization strategy provides a production-ready, secure, and scalable deployment for Agentgateway with comprehensive monitoring and operational excellence.