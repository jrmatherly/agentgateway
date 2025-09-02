# Grafana Provisioning Configuration

This directory contains Grafana provisioning configurations that are automatically loaded when Grafana starts.

## Structure

```
grafana-provisioning/
├── datasources/
│   └── datasources.yml          # Auto-provisions Prometheus & Jaeger
├── dashboards/
│   └── default.yml              # Auto-provisions dashboards from /var/lib/grafana/dashboards/
├── notifiers/
│   └── default.yml              # Alert notification channels (optional)
└── plugins/                     # Plugin configurations (future use)
```

## Configuration Details

### Datasources (`datasources/datasources.yml`)
- **Prometheus**: Primary metrics datasource connected to `http://prometheus:9090`
- **Jaeger**: Distributed tracing datasource connected to `http://jaeger:16686`
- **Integration**: Exemplar links from Prometheus → Jaeger traces

### Dashboards (`dashboards/default.yml`)
- Auto-loads dashboards from `/var/lib/grafana/dashboards/`
- Creates "Agentgateway" folder in Grafana UI
- Updates dashboards automatically every 30 seconds

### Validation

The configuration follows official Grafana provisioning format:
- Uses `apiVersion: 1` (current stable API)
- Includes proper UIDs for cross-datasource references
- Schema hints prevent IDE validation errors

## Docker Compose Integration

These files are mounted in the container at `/etc/grafana/provisioning/`:

```yaml
volumes:
  - ./manifests/grafana-provisioning:/etc/grafana/provisioning
```

## References

- [Grafana Provisioning Documentation](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [Datasource Configuration](https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources)
- [Dashboard Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)