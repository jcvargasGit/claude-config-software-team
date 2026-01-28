---
name: observability
description: Structured logging, error tracking, and request tracing principles for production systems.
---

# Observability Skill

Apply these logging and observability principles for production-ready applications. This skill covers concepts - see `lang-*` skills for language-specific implementations.

## Core Principles

### Structured Logging

Use structured (JSON) logging instead of plain text:

**Why:**
- Machine-parseable (CloudWatch Insights, Datadog, etc.)
- Consistent format across services
- Enables filtering and aggregation
- Better for distributed tracing

**What to include:**
| Field | Purpose | Example |
|-------|---------|---------|
| timestamp | When it happened | ISO 8601 format |
| level | Severity | info, warn, error |
| message | What happened | "request handled" |
| service | Which service | "auth", "users" |
| stage | Environment | "dev", "prod" |
| requestId | Correlation | UUID from request |

### Log Levels

Use appropriate log levels:

| Level | When to Use | Examples |
|-------|-------------|----------|
| **debug** | Development troubleshooting | Variable values, flow tracing |
| **info** | Normal operations | Request completed, job started |
| **warn** | Recoverable issues, client errors | 4xx responses, validation failures |
| **error** | System failures, unexpected errors | 5xx responses, external service down |
| **fatal** | Unrecoverable, app must stop | Startup failure, missing config |

### HTTP Response to Log Level Mapping

| Status Code | Log Level | Rationale |
|-------------|-----------|-----------|
| 2xx | info | Normal operation |
| 4xx | warn | Client error, not our fault |
| 5xx | error | Server error, needs attention |

## Error Logging

### What to Log on Errors

Always include context when logging errors:

| Field | Purpose |
|-------|---------|
| error | The error message/type |
| operation | What was being attempted |
| status | HTTP status code |
| userId | Who was affected (if applicable) |
| input | Sanitized input that caused error |

### Error Logging Pattern

```
On error:
  1. Determine severity (4xx = warn, 5xx = error)
  2. Log with context (operation, status, error)
  3. Return appropriate response to client
```

### What NOT to Log

- Passwords or tokens
- Full credit card numbers
- Personal identifiable information (PII)
- Session secrets
- API keys

## Request Tracing

### Correlation IDs

Every request should have a unique identifier that flows through all services:

1. **Generate or extract** ID at entry point (API Gateway, load balancer)
2. **Propagate** ID to all downstream calls
3. **Include** ID in all log entries
4. **Return** ID in error responses (helps debugging)

### Common Header Names

| Header | Description |
|--------|-------------|
| X-Request-ID | Generic request identifier |
| X-Correlation-ID | Cross-service trace identifier |
| X-Amzn-Trace-Id | AWS X-Ray trace ID |

### Trace Context

When calling downstream services, propagate:
- Request ID
- Parent span ID (for distributed tracing)
- User context (if applicable)

## Service Context

### What to Include

Add consistent context to all logs:

| Field | Source | Purpose |
|-------|--------|---------|
| service | Configuration | Identify which service |
| stage | Environment variable | Identify environment |
| version | Build info | Identify deployment |
| region | Environment | Geographic location |

### Initialize Once

Set service context at startup, not per-request. This reduces overhead and ensures consistency.

## Logging Patterns

### Request Logging

Log at the start and end of request processing:

**Entry log (optional, can be noisy):**
- method, path
- requestId

**Exit log (always):**
- method, path, status
- duration
- requestId

### Error Response Logging

When returning an error response:

```
1. Map error to status code
2. Determine log level (warn for 4xx, error for 5xx)
3. Log with: error, operation, status
4. Return sanitized error to client
```

### Background Job Logging

For async processes:
- Log job start with job ID
- Log significant milestones
- Log completion with duration
- Log failures with full context

## Observability Checklist

- [ ] Using structured (JSON) logging
- [ ] Log levels used correctly (warn for 4xx, error for 5xx)
- [ ] Errors logged with context (operation, status)
- [ ] Request ID propagated and logged
- [ ] Service context included in all logs
- [ ] Sensitive data excluded from logs
- [ ] Request duration tracked
- [ ] Logs parseable by monitoring tools

## Anti-Patterns

### Don't Do This

- **Logging sensitive data**: Passwords, tokens, PII
- **Inconsistent formats**: Mixing JSON and plain text
- **Missing context**: Logging errors without operation info
- **Wrong levels**: Using error for validation failures
- **Silent failures**: Catching errors without logging
- **Over-logging**: Debug level in production
- **Under-logging**: No visibility into failures

### Do This Instead

- **Structured JSON logs**: Consistent, parseable format
- **Context on errors**: Always include operation, status
- **Appropriate levels**: Warn for client errors, error for server errors
- **Correlation IDs**: Trace requests across services
- **Sanitized output**: Remove sensitive data before logging

## Language-Specific Implementation

See language-specific skills for implementation details:
- `lang-golang` - zerolog patterns
- `lang-typescript` - pino/winston patterns
- `lang-python` - structlog patterns

## Integration with Cloud Services

### AWS CloudWatch

- Logs automatically captured from Lambda
- Use CloudWatch Insights for querying JSON logs
- Set up metric filters for error rates
- Create dashboards for key metrics

### Alerting

Set up alerts for:
- Error rate spikes
- High latency percentiles (p95, p99)
- Failed health checks
- Resource exhaustion (memory, connections)
