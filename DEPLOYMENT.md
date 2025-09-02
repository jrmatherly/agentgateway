# Agentgateway Deployment Guide

This document explains how to deploy Agentgateway using Docker Compose with different strategies.

## 🐳 Docker Compose Deployment Strategies

### Development Deployment
```bash
# Build and run locally with development settings
docker-compose up -d
```

### Production Deployment - Hybrid Strategy
```bash
# Production deployment with hybrid pull/build strategy
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Force build (skip image pull)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Pull only (fail if image not available)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-build
```

### Development with Overrides
```bash
# Development with local overrides
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

## 🏗️ Image Build Strategy

### Hybrid Pull/Build (Production Default)
The production configuration uses a hybrid strategy:

1. **First**: Attempts to pull `ghcr.io/agentgateway/agentgateway:v1.0.0` from registry
2. **Fallback**: Builds locally using `Dockerfile` if image is not available
3. **Benefits**: 
   - ✅ Fast deployments when image is available
   - ✅ Local testing without registry dependency
   - ✅ CI/CD friendly with pre-built images

### Force Specific Strategy

```bash
# Force local build (ignore registry)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Force registry pull (fail if not available)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-build
```

## 🔧 Environment Configuration

### Required Environment Variables

Create a `.env` file for production:
```bash
# Copy example and customize
cp .env.example .env

# Essential variables for production
REDIS_PASSWORD=your_secure_redis_password
POSTGRES_PASSWORD=your_secure_postgres_password
GF_SECURITY_ADMIN_PASSWORD=your_secure_grafana_password
```

### Kubernetes Environment Variables

For Kubernetes deployment, also reference:
```bash
# Kubernetes-specific variables
cp .env.k8s.example .env.k8s
```

## 📊 Services Overview

| Service | Port | Purpose | Health Check |
|---------|------|---------|--------------|
| **agentgateway** | 3000, 8080 | Main application & metrics | `/metrics` |
| **postgres** | 5432 | Database | `pg_isready` |
| **redis** | 6379 | Cache | `redis-cli ping` |
| **prometheus** | 9090 | Metrics collection | Web UI |
| **grafana** | 3001 | Monitoring dashboards | Web UI |
| **jaeger** | 16686, 14268, 4317, 4318 | Distributed tracing | Web UI |
| **otel-collector** | 8888 | Telemetry processing & metrics | Health endpoint |

## 🚀 Verification

### Check Service Health
```bash
# View all service status
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps

# Check logs
docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs agentgateway

# Test health endpoints
curl http://localhost:8080/metrics  # Agentgateway metrics
curl http://localhost:9090/-/healthy  # Prometheus health
curl http://localhost:3001/api/health  # Grafana health
```

### Access Web Interfaces
- **Agentgateway**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001 (admin/your_password)
- **Jaeger**: http://localhost:16686

## 🔒 Production Security

### Security Features Enabled
- ✅ Non-root containers
- ✅ Read-only file systems
- ✅ No new privileges
- ✅ Resource limits
- ✅ Health checks
- ✅ Proper secret management

### Security Recommendations
1. **Change default passwords** in `.env` file
2. **Use TLS certificates** for external access
3. **Configure firewalls** to restrict access
4. **Regular updates** of base images
5. **Monitor logs** for security events

## 🐛 Troubleshooting

### Common Issues

**Image Pull Fails**:
```bash
# Force local build
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

**Port Conflicts**:
```bash
# Check what's using ports
lsof -i :3000 -i :3001 -i :5432 -i :6379 -i :9090
```

**Permission Issues**:
```bash
# Fix volume permissions
sudo chown -R 65532:65532 ./data/
```

**Service Won't Start**:
```bash
# Check specific service logs
docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs <service_name>

# Restart specific service
docker-compose -f docker-compose.yml -f docker-compose.prod.yml restart <service_name>
```