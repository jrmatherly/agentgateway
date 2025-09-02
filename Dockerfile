ARG BUILDER=base

FROM docker.io/library/node:22-bookworm AS node

WORKDIR /app

COPY ui .

RUN --mount=type=cache,target=/app/npm/cache npm install

RUN --mount=type=cache,target=/app/npm/cache npm run build

FROM docker.io/library/rust:1.89.0-slim-bookworm AS musl-builder

ARG TARGETARCH

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  rm -f /etc/apt/apt.conf.d/docker-clean && \
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
  apt-get update && apt-get install -y --no-install-recommends \
  make musl-tools

RUN <<EOF
mkdir /build
if [ "$TARGETARCH" = "arm64" ]; then
  rustup target add aarch64-unknown-linux-musl;
  echo aarch64-unknown-linux-musl > /build/target
else
  rustup target add x86_64-unknown-linux-musl;
  echo x86_64-unknown-linux-musl > /build/target
fi
EOF

FROM docker.io/library/rust:1.89.0-slim-bookworm AS base-builder

ARG TARGETARCH

RUN <<EOF
mkdir /build
if [ "$TARGETARCH" = "arm64" ]; then
  echo aarch64-unknown-linux-gnu > /build/target
else
  echo x86_64-unknown-linux-gnu > /build/target
fi
echo "Building $(cat /build/target)"
EOF

FROM ${BUILDER}-builder AS builder
ARG TARGETARCH
ARG PROFILE=release

# Validate PROFILE argument
RUN if [ "$PROFILE" != "release" ] && [ "$PROFILE" != "debug" ] && [ "$PROFILE" != "dev" ]; then \
  echo "Invalid PROFILE: $PROFILE. Must be release, debug, or dev" && exit 1; fi

WORKDIR /app

COPY Makefile Cargo.toml Cargo.lock ./
COPY crates ./crates
COPY common ./common
COPY --from=node /app/out ./ui/out

RUN --mount=type=cache,id=cargo,target=/usr/local/cargo/registry \
  cargo fetch --locked
RUN --mount=type=cache,target=/app/target \
  --mount=type=cache,id=cargo,target=/usr/local/cargo/registry \
  cargo build --features ui  --target "$(cat /build/target)"  --profile ${PROFILE} && \
  mkdir /out && \
  mv /app/target/$(cat /build/target)/${PROFILE}/agentgateway /out

FROM gcr.io/distroless/cc-debian12 AS runner 

ARG TARGETARCH
ARG VERSION=dev
ARG BUILD_DATE
ARG VCS_REF

# Create non-root user (distroless already provides 'nonroot' user with UID 65532)
WORKDIR /app

# Copy binary with proper ownership
COPY --from=builder --chown=65532:65532 /out/agentgateway /app/agentgateway

# Add comprehensive labels
LABEL org.opencontainers.image.title="Agentgateway"
LABEL org.opencontainers.image.description="High-performance data plane for agentic AI connectivity with Agent2Agent (A2A) and Model Context Protocol (MCP) support"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.vendor="Agentgateway Project"
LABEL org.opencontainers.image.source="https://github.com/agentgateway/agentgateway"
LABEL org.opencontainers.image.url="https://github.com/agentgateway/agentgateway"
LABEL org.opencontainers.image.documentation="https://github.com/agentgateway/agentgateway/blob/main/README.md"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# Security labels
LABEL security.scan-policy="strict"
LABEL security.non-root="true"
LABEL security.capabilities="none"

# Set proper file permissions
USER 65532:65532

# Expose default ports
EXPOSE 3000 8080

# Set environment variables for security
ENV RUST_LOG=info
ENV RUST_BACKTRACE=0

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD ["/app/agentgateway", "--validate-only"]

ENTRYPOINT ["/app/agentgateway"]
