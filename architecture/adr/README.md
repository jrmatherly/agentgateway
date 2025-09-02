# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records (ADRs) for the Agentgateway project. ADRs document the significant architectural decisions made during the development of the project, including the context, options considered, and rationale behind each decision.

## What are ADRs?

Architecture Decision Records are lightweight documents that capture important architectural decisions along with their context and consequences. They help teams:

- **Document decision rationale** for future team members
- **Avoid revisiting settled decisions** without new information
- **Understand the evolution** of the architecture over time
- **Learn from past decisions** and their outcomes

## ADR Format

Each ADR follows a standard format with the following sections:

- **Status**: Proposed, Accepted, Deprecated, or Superseded
- **Date**: When the decision was made
- **Context**: The situation that led to the decision
- **Decision**: What was decided
- **Consequences**: The implications of the decision

## ADR Lifecycle

1. **Proposed**: Initial ADR draft for discussion
2. **Accepted**: Decision is approved and implemented
3. **Deprecated**: Decision is no longer recommended but not replaced
4. **Superseded**: Decision is replaced by a newer ADR

## Naming Convention

ADRs are numbered sequentially with descriptive titles:
- `0001-use-rust-for-core-proxy.md`
- `0002-adopt-tokio-async-runtime.md`
- `0003-implement-xds-configuration.md`

## Current ADRs

| # | Status | Title | Date |
|---|--------|-------|------|
| [0001](0001-use-rust-for-core-proxy.md) | ✅ Accepted | Use Rust for Core Proxy Implementation | 2024-10-01 |
| [0002](0002-adopt-tokio-async-runtime.md) | ✅ Accepted | Adopt Tokio for Async Runtime | 2024-10-15 |
| [0003](0003-single-binary-deployment.md) | ✅ Accepted | Single Binary Deployment Model | 2024-11-01 |
| [0004](0004-xds-configuration-discovery.md) | ✅ Accepted | xDS for Configuration Discovery | 2024-11-15 |
| [0005](0005-nextjs-web-ui.md) | ✅ Accepted | Next.js for Web UI Implementation | 2024-12-01 |
| [0006](0006-jwt-authentication.md) | ✅ Accepted | JWT-based Authentication | 2024-12-10 |
| [0007](0007-cel-policy-language.md) | ✅ Accepted | CEL for Policy Expression Language | 2024-12-15 |

## Creating New ADRs

To create a new ADR:

1. **Identify the decision** that needs to be documented
2. **Assign the next sequential number** (check existing ADRs)
3. **Use the ADR template** (see `template.md`)
4. **Fill in all sections** with relevant information
5. **Submit for review** via pull request
6. **Update this README** with the new ADR entry

## ADR Template

```markdown
# [Number]. [Title]

Date: YYYY-MM-DD

## Status

[Proposed | Accepted | Deprecated | Superseded by [ADR-XXXX]]

## Context

[What is the issue that we're seeing that is motivating this decision or change?]

## Decision

[What is the change that we're proposing and/or doing?]

## Alternatives Considered

[What other options were considered and why were they rejected?]

## Consequences

[What becomes easier or more difficult to do because of this change?]

### Positive
- [List positive consequences]

### Negative  
- [List negative consequences]

### Neutral
- [List neutral consequences]

## Implementation Notes

[Any specific implementation guidance or requirements]

## References

- [Link to relevant discussions, RFCs, documentation]
```

## Review Process

1. **Author** creates ADR draft with status "Proposed"
2. **Team** reviews and discusses the ADR
3. **Stakeholders** provide feedback and concerns
4. **Author** incorporates feedback and updates ADR
5. **Team** approves ADR and status changes to "Accepted"
6. **Implementation** begins based on ADR guidance

## ADR Maintenance

- ADRs are **immutable** once accepted (do not edit historical decisions)
- Use **superseding ADRs** to change or reverse previous decisions
- **Link related ADRs** to show evolution of thinking
- **Update status** when decisions are deprecated or superseded
- **Regular review** to ensure ADRs remain relevant and accurate

## Tools and Automation

- **ADR CLI**: Consider using [adr-tools](https://github.com/npryce/adr-tools) for ADR management
- **Automatic Linking**: Link ADRs to relevant code changes via commit messages
- **Status Tracking**: Automated status updates based on implementation progress
- **Archive Management**: Automated archival of superseded ADRs