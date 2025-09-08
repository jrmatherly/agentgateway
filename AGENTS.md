# AGENTS.md
This file provides guidance to AI coding assistants working in this repository.

**Note:** CLAUDE.md, .clinerules, .cursorrules, .windsurfrules, and other AI config files are symlinks to AGENTS.md in this project.

# Agentgateway

**Agentgateway** is an open source data plane optimized for agentic AI connectivity, written primarily in Rust with a Next.js UI. It provides drop-in security, observability, and governance for agent-to-agent and agent-to-tool communication, supporting protocols like Agent2Agent (A2A) and Model Context Protocol (MCP).

## Build & Commands

### Core Development Commands

**Rust Backend (Primary):**
- Build: `make build` (builds release binary with UI features)
- Build debug: `cargo build --features ui`
- Test: `make test` (runs `cargo test --all-targets`)
- Lint: `make lint` (runs `cargo fmt --check` + `cargo clippy --all-targets -- -D warnings`)
- Fix linting: `make fix-lint` (auto-fixes with clippy and fmt)
- Clean: `make clean` (runs `cargo clean`)

**UI Development (`cd ui` first):**
- Install: `npm install`
- Dev server: `npm run dev` (Next.js with Turbopack)
- Build: `npm run build` (includes linting step)
- Lint: `npm run lint` (ESLint with auto-fix)
- Lint check: `npm run lint:check` (check only)
- Start production: `npm run start`

### Code Generation & Schema
- Generate all: `make gen` (APIs + schema + fix linting)
- Generate APIs: `make generate-apis` (protobuf/xDS APIs)
- Generate schema: `make generate-schema` (JSON schemas via `cargo xtask schema`)

### Docker & Container
- Build Docker: `make docker`
- Build musl variant: `make docker-musl`

### Testing & Validation
- Run tests: `make test`
- Validate configs: `make validate` (validates example configurations)
- Start test deps: `make run-validation-deps`
- Stop test deps: `make stop-validation-deps`

### Complete Development Build Process
```bash
# 1. Build UI first
cd ui
npm install
npm run build

# 2. Build Rust binary
cd ..
make build

# 3. Run application
./target/release/agentgateway
# UI accessible at: http://localhost:15000/ui
```

### Script Command Consistency
**Important**: When modifying npm scripts in `ui/package.json`, ensure all references are updated:
- GitHub Actions workflows (`.github/workflows/*.yml`)
- README.md documentation
- DEVELOPMENT.md instructions
- Docker configuration files
- Makefile references

## Code Style

### Rust Formatting (rustfmt.toml)
- **Tabs**: Hard tabs enabled (`hard_tabs = true`)
- **Tab width**: 2 spaces equivalent (`tab_spaces = 2`)
- **Trailing commas**: Required in match blocks (`match_block_trailing_comma = true`)
- **Linting**: Clippy with warnings as errors (`-D warnings`)

### TypeScript/React Formatting (.eslintrc.json)
- **Style**: Prettier integration with Next.js + TypeScript
- **Quotes**: Double quotes preferred (`singleQuote: false`)
- **Semicolons**: Required (`semi: true`)
- **Indentation**: 2 spaces (`tabWidth: 2`)
- **Trailing commas**: ES5 style (`trailingComma: "es5"`)

### Naming Conventions
**Rust:**
- `snake_case` for functions, variables, modules
- `PascalCase` for types, structs, enums
- `SCREAMING_SNAKE_CASE` for constants
- Crate names: `kebab-case` (e.g., `agentgateway`, `a2a-sdk`)

**TypeScript/React:**
- `camelCase` for variables, functions
- `PascalCase` for components, interfaces, types
- `kebab-case` for file names
- Interface preferred over type alias (`@typescript-eslint/consistent-type-definitions`)

### Import Conventions
**Rust:**
```rust
// Standard library first
use std::collections::HashMap;
use std::sync::Arc;

// External crates
use anyhow::Result;
use serde::{Deserialize, Serialize};

// Internal crates
use agent_core::prelude::*;
use crate::config::Config;
```

**TypeScript:**
```typescript
// React/Next.js first
import React from "react";
import { NextPage } from "next";

// External libraries
import { Button } from "@radix-ui/react-button";

// Internal imports
import { ConfigData } from "@/lib/types";
import { useConfig } from "@/hooks/useConfig";
```

### Error Handling Patterns
**Rust:**
- Use `anyhow::Result<T>` for application errors
- Use `thiserror` for custom error types
- Avoid `unwrap()` and `expect()` in production code paths
- Prefer `?` operator for error propagation

**TypeScript:**
- Use proper error boundaries in React components
- Handle async errors with try/catch
- Use Result-like patterns for API responses

## Testing

### Frameworks & Tools
- **Rust**: Cargo test with `insta` for snapshot testing, `wiremock` for HTTP mocking
- **Integration**: Mock server crate (`crates/mock-server`)
- **Benchmarks**: Divan for performance testing
- **TypeScript**: Jest/Testing Library (if configured)

### Test File Patterns
- **Rust**: `tests/` directories, `*_tests.rs` files, inline `#[cfg(test)]` modules
- **Integration**: `crates/agentgateway/tests/`
- **Examples**: Configuration validation in `examples/*/config.yaml`

### Testing Conventions
- **Unit tests**: Test individual functions and modules
- **Integration tests**: Test component interactions via mock server
- **Configuration tests**: Validate example configs with `--validate-only`
- **Snapshot tests**: Use insta for regression testing

### Running Specific Tests
```bash
# Run specific test
cargo test test_name

# Run tests in specific crate
cargo test -p agentgateway

# Run integration tests only
cargo test --test integration

# Run with output
cargo test -- --nocapture

# Update snapshots
cargo insta review
```

### Testing Philosophy
**When tests fail, fix the code, not the test.**

Key principles:
- **Tests should be meaningful** - Avoid tests that always pass regardless of behavior
- **Test actual functionality** - Call the functions being tested, don't just check side effects
- **Failing tests are valuable** - They reveal bugs or missing features
- **Fix the root cause** - When a test fails, fix the underlying issue, don't hide the test
- **Test edge cases** - Tests that reveal limitations help improve the code
- **Document test purpose** - Each test should include a comment explaining why it exists and what it validates

## Security

### Authentication & Authorization
- **MCP Authentication**: OAuth2/JWT with JWKS validation
- **Multi-provider Support**: Keycloak, Auth0, custom providers
- **RBAC System**: Role-based access control for MCP/A2A traffic
- **Secret Management**: Use `secrecy::SecretString` for sensitive data
- **Never log secrets**: Implement `serialize_with = "ser_redact"` for secret fields

### Protocol Security
- **TLS**: rustls with ring crypto, client certificate authentication
- **JWT Verification**: Multiple provider support with audience validation
- **Rate Limiting**: Both local and remote rate limiting capabilities
- **CORS**: Configurable cross-origin resource sharing policies

### Development Security Practices
```rust
// ✅ Good: Use SecretString for sensitive data
#[serde(serialize_with = "ser_redact")]
#[cfg_attr(feature = "schema", schemars(with = "String"))]
access_key: SecretString,

// ❌ Bad: Plain string for secrets
access_key: String,
```

## Directory Structure & File Organization

### Core Project Structure
```
agentgateway/
├── crates/                    # Rust workspace
│   ├── agentgateway/         # Main application
│   ├── core/                 # Shared utilities
│   ├── a2a-sdk/              # Agent2Agent SDK
│   ├── hbone/                # HBONE protocol
│   ├── xds/                  # xDS integration
│   └── mock-server/          # Testing utilities
├── ui/                       # Next.js frontend
│   ├── src/app/              # Next.js App Router
│   ├── src/components/       # React components
│   └── src/lib/              # Utilities and hooks
├── examples/                 # Configuration examples
├── schema/                   # JSON schemas
└── reports/                  # Project reports and documentation
```

### Reports Directory
ALL project reports and documentation should be saved to the `reports/` directory:

```
agentgateway/
├── reports/              # All project reports and documentation
│   └── *.md             # Various report types
├── temp/                # Temporary files and debugging
└── [other directories]
```

### Report Generation Guidelines
**Important**: ALL reports should be saved to the `reports/` directory with descriptive names:

**Implementation Reports:**
- Phase validation: `PHASE_X_VALIDATION_REPORT.md`
- Implementation summaries: `IMPLEMENTATION_SUMMARY_[FEATURE].md`
- Feature completion: `FEATURE_[NAME]_REPORT.md`

**Testing & Analysis Reports:**
- Test results: `TEST_RESULTS_[DATE].md`
- Coverage reports: `COVERAGE_REPORT_[DATE].md`
- Performance analysis: `PERFORMANCE_ANALYSIS_[SCENARIO].md`
- Security scans: `SECURITY_SCAN_[DATE].md`

**Quality & Validation:**
- Code quality: `CODE_QUALITY_REPORT.md`
- Dependency analysis: `DEPENDENCY_REPORT.md`
- API compatibility: `API_COMPATIBILITY_REPORT.md`

**Report Naming Conventions:**
- Use descriptive names: `[TYPE]_[SCOPE]_[DATE].md`
- Include dates: `YYYY-MM-DD` format
- Group with prefixes: `TEST_`, `PERFORMANCE_`, `SECURITY_`
- Markdown format: All reports end in `.md`

### Temporary Files & Debugging
All temporary files, debugging scripts, and test artifacts should be organized in a `/temp` folder:

**Temporary File Organization:**
- **Debug scripts**: `temp/debug-*.js`, `temp/analyze-*.py`
- **Test artifacts**: `temp/test-results/`, `temp/coverage/`
- **Generated files**: `temp/generated/`, `temp/build-artifacts/`
- **Logs**: `temp/logs/debug.log`, `temp/logs/error.log`

**Guidelines:**
- Never commit files from `/temp` directory
- Use `/temp` for all debugging and analysis scripts created during development
- Clean up `/temp` directory regularly or use automated cleanup
- Include `/temp/` in `.gitignore` to prevent accidental commits

### Claude Code Settings (.claude Directory)

The `.claude` directory contains Claude Code configuration files with specific version control rules:

#### Version Controlled Files (commit these):
- `.claude/settings.json` - Shared team settings for hooks, tools, and environment
- `.claude/commands/*.md` - Custom slash commands available to all team members
- `.claude/hooks/*.sh` - Hook scripts for automated validations and actions

#### Ignored Files (do NOT commit):
- `.claude/settings.local.json` - Personal preferences and local overrides
- Any `*.local.json` files - Personal configuration not meant for sharing

**Important Notes:**
- Claude Code automatically adds `.claude/settings.local.json` to `.gitignore`
- The shared `settings.json` should contain team-wide standards (linting, type checking, etc.)
- Personal preferences or experimental settings belong in `settings.local.json`
- Hook scripts in `.claude/hooks/` should be executable (`chmod +x`)

## Configuration

### Environment Setup Requirements
- **Rust**: 1.89+ (Edition 2024)
- **Node.js**: 10+ with npm
- **Protocol Buffers**: buf CLI for code generation
- **Docker**: For containerized builds

### Configuration Management
- **Primary**: YAML-based configuration files
- **Schema**: JSON Schema validation (`schema/local.json`)
- **xDS Integration**: Envoy xDS protocol for dynamic updates
- **Hot Reload**: Configuration updates without restart
- **Examples**: Comprehensive examples in `examples/` directory

### Key Configuration Areas
- **Routing**: HTTP/TCP routing with advanced policies
- **Backends**: MCP servers, AI providers, OpenAPI services
- **Authentication**: OAuth2, JWT, API keys, client certificates
- **Policies**: CORS, rate limiting, request/response transformations
- **Observability**: Metrics, tracing, logging configuration

### Development Environment Variables
```bash
# Optional environment variables
export IPV6_ENABLED=true
export LOCAL_XDS_PATH=/path/to/config.yaml
export XDS_ADDRESS=http://xds-server:8080
export RUST_LOG=debug
```

## Agent Delegation & Tool Execution

### ⚠️ MANDATORY: Always Delegate to Specialists & Execute in Parallel

**When specialized agents are available, you MUST use them instead of attempting tasks yourself.**

**When performing multiple operations, send all tool calls (including Task calls for agent delegation) in a single message to execute them concurrently for optimal performance.**

#### Why Agent Delegation Matters:
- Specialists have deeper, more focused knowledge
- They're aware of edge cases and subtle bugs  
- They follow established patterns and best practices
- They can provide more comprehensive solutions

#### Key Principles:
- **Agent Delegation**: Always check if a specialized agent exists for your task domain
- **Complex Problems**: Delegate to domain experts, use diagnostic agents when scope is unclear
- **Multiple Agents**: Send multiple Task tool calls in a single message to delegate to specialists in parallel
- **DEFAULT TO PARALLEL**: Unless you have a specific reason why operations MUST be sequential (output of A required for input of B), always execute multiple tools simultaneously
- **Plan Upfront**: Think "What information do I need to fully answer this question?" Then execute all searches together

#### Critical: Always Use Parallel Tool Calls

**Err on the side of maximizing parallel tool calls rather than running sequentially.**

**IMPORTANT: Send all tool calls in a single message to execute them in parallel.**

**These cases MUST use parallel tool calls:**
- Searching for different patterns (imports, usage, definitions)
- Multiple grep searches with different regex patterns
- Reading multiple files or searching different directories
- Combining Glob with Grep for comprehensive results
- Searching for multiple independent concepts
- Any information gathering where you know upfront what you're looking for
- Agent delegations with multiple Task calls to different specialists

**Sequential calls ONLY when:**
You genuinely REQUIRE the output of one tool to determine the usage of the next tool.

**Planning Approach:**
1. Before making tool calls, think: "What information do I need to fully answer this question?"
2. Send all tool calls in a single message to execute them in parallel
3. Execute all those searches together rather than waiting for each result
4. Most of the time, parallel tool calls can be used rather than sequential

**Performance Impact:** Parallel tool execution is 3-5x faster than sequential calls, significantly improving user experience.

**Remember:** This is not just an optimization—it's the expected behavior. Both delegation and parallel execution are requirements, not suggestions.

## Architecture & Design Patterns

### Multi-Crate Workspace
- **Modular Design**: Clear separation of concerns across crates
- **Protocol Abstraction**: Common interfaces for A2A, MCP, HTTP
- **Async-First**: Tokio-based async runtime throughout
- **Zero-Copy**: Minimize allocations in hot paths

### Key Design Principles
- **Security by Default**: All communication secured with TLS
- **Configuration-Driven**: Behavior controlled via YAML/xDS
- **Multi-Tenant**: Namespace isolation and resource management
- **High Performance**: Rust's zero-cost abstractions + careful optimization

### Protocol Support
- **Model Context Protocol (MCP)**: First-class support with OAuth2 auth
- **Agent2Agent (A2A)**: Google's agent interoperability protocol
- **OpenAPI Translation**: Legacy REST APIs → MCP resources
- **Standard HTTP/TCP**: Reverse proxy capabilities

### AI Provider Integration
- **Multi-LLM**: OpenAI, Anthropic, Google Gemini, AWS Bedrock, Vertex AI
- **Streaming**: Real-time response streaming support  
- **Token Management**: Accurate rate limiting with tokenization
- **Prompt Guards**: Request/response filtering and content moderation