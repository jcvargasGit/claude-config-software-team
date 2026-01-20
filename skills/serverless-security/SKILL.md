---
name: serverless-security
description: Apply security best practices for serverless applications including input validation, secrets management, and OWASP serverless top 10.
---

# Serverless Security Skill

Apply security best practices for serverless applications.

## OWASP Serverless Top 10

| Risk | Description | Mitigation |
|------|-------------|------------|
| Injection | Code injection via event data | Validate all inputs at entry point |
| Broken Authentication | Weak token handling | Use managed auth services, validate tokens |
| Sensitive Data Exposure | Secrets in code/logs | Use secret managers, sanitize logs |
| Insecure Deserialization | Untrusted event data | Validate and sanitize before processing |
| Insufficient Logging | Missing audit trails | Structured logging with correlation IDs |
| Broken Access Control | Over-privileged functions | Least privilege IAM, per-function roles |
| Security Misconfiguration | Default/weak settings | Infrastructure as code, security scanning |
| DoS | Resource exhaustion | Concurrency limits, timeouts, rate limiting |
| Component Vulnerabilities | Outdated dependencies | Dependency scanning, regular updates |
| Event Injection | Malicious event payloads | Input validation, schema enforcement |

## Input Validation

### Validate at Gateway Level

API Gateway is the first line of defense:

- Request validation against OpenAPI schemas
- Parameter constraints (min/max, patterns)
- Required fields enforcement
- Content-type validation

### Handler Validation

Always validate inside handlers too (defense in depth):

- Type coercion and validation
- Business rule validation
- Authorization checks
- Sanitization before use

### Schema-Based Validation

Use schema libraries for consistent validation:

- Define schemas once, reuse everywhere
- Generate types from schemas
- Fail fast with clear error messages
- Log validation failures for monitoring

## Secrets Management

### Secret Storage Options

| Option | Use Case | Trade-offs |
|--------|----------|------------|
| AWS Secrets Manager | API keys, credentials | Auto-rotation, costs per secret |
| Parameter Store | Config values | Free tier, no rotation |
| Environment variables | Non-sensitive config | Fast access, no versioning |

### Secret Access Pattern

1. Retrieve secrets at cold start (not per request)
2. Cache secrets in memory with TTL
3. Handle secret rotation gracefully
4. Never log secret values

### What Goes Where

| Secret Type | Storage |
|-------------|---------|
| Database credentials | Secrets Manager (rotation) |
| Third-party API keys | Secrets Manager |
| Feature flags | Parameter Store |
| Public configuration | Environment variables |
| JWT signing keys | Secrets Manager |

## Token Validation

### JWT Validation Checklist

- [ ] Verify signature with correct algorithm
- [ ] Check token expiration (exp claim)
- [ ] Validate issuer (iss claim)
- [ ] Verify audience (aud claim)
- [ ] Check not-before time (nbf claim)
- [ ] Validate required custom claims

### Token Best Practices

- Short expiration times (15-60 minutes)
- Refresh tokens for session extension
- Revocation strategy for compromised tokens
- Audience restriction per service

### MFA Patterns

| Pattern | When to Use |
|---------|-------------|
| Step-up authentication | Sensitive operations |
| Time-based challenge | Login from new device |
| Risk-based challenge | Anomalous behavior detected |

## Authorization Patterns

### Claims-Based Authorization

Use JWT claims for fine-grained access:

- Role claims for RBAC
- Permission claims for ABAC
- Resource-specific claims
- Scope claims for API access

### Custom Authorizer Pattern

Lambda authorizers for complex logic:

- Centralized authorization logic
- Caching for performance
- Rich context propagation
- External identity provider integration

### Authorization Response Caching

- Cache positive authorizations (5-15 min)
- Shorter cache for sensitive endpoints
- Consider cache invalidation strategy
- Balance security vs latency

## Function-Level Security

### Least Privilege Principle

Each function should have:

- Only permissions it needs
- Only to resources it accesses
- Only actions it performs
- No wildcard permissions

### Role Design Pattern

| Approach | Pros | Cons |
|----------|------|------|
| One role per function | Minimal blast radius | More roles to manage |
| Shared role per service | Easier management | Broader permissions |
| Shared + specific | Balance | Some complexity |

### Resource Constraints

Define resource-level constraints:

- Specific ARNs over wildcards
- Condition keys for extra restrictions
- Tag-based access control
- Account and region scoping

## Environment Variable Security

### Sensitive vs Non-Sensitive

| Sensitive (avoid in env vars) | Non-Sensitive (OK in env vars) |
|------------------------------|-------------------------------|
| Database passwords | Table names |
| API keys | Region |
| Private keys | Log level |
| Connection strings with creds | Feature toggles |

### Encryption Options

- AWS encrypts env vars at rest by default
- Use KMS for sensitive values
- Decrypt at cold start, cache result
- Consider Secrets Manager for rotation

## Logging Security

### What NOT to Log

- Passwords and secrets
- Full credit card numbers
- Personal identifiable information (PII)
- Session tokens
- API keys

### Log Sanitization

- Mask sensitive fields before logging
- Use structured logging for consistent masking
- Redact query parameters with secrets
- Implement log scrubbing

### Audit Logging

| Event | Required Fields |
|-------|-----------------|
| Authentication | User ID, result, IP, timestamp |
| Authorization | User ID, resource, action, result |
| Data access | User ID, resource, operation |
| Admin actions | Actor, target, action, timestamp |

## Security Testing

### What to Test

| Test Type | Focus |
|-----------|-------|
| Unit | Input validation, error handling |
| Integration | IAM permissions, auth flows |
| Security scan | Dependencies, configurations |
| Penetration | Attack vectors, misconfigurations |

### Automated Security Checks

- Dependency vulnerability scanning
- Static code analysis
- Infrastructure policy checks
- Secret detection in code

## Network Security

### VPC Considerations

| Scenario | VPC Needed |
|----------|-----------|
| Database access | Yes |
| Internal APIs | Yes |
| Public APIs only | No |
| Third-party APIs | No |

### VPC Security Groups

- Outbound only by default
- Restrict to required ports
- Use security group references
- Separate by function purpose

## Common Vulnerabilities

### Event Injection

**Risk**: Malicious data in event sources (S3, SQS, etc.)

**Mitigation**:
- Validate event structure
- Sanitize file names and paths
- Verify event source identity
- Use dead letter queues for failures

### Execution Role Abuse

**Risk**: Overprivileged roles enable lateral movement

**Mitigation**:
- One role per function
- Principle of least privilege
- Regular permission audits
- Remove unused permissions

### Cold Start Token Exposure

**Risk**: Tokens logged during initialization

**Mitigation**:
- Don't log during init
- Sanitize all log output
- Use structured logging
- Review CloudWatch logs

## Quality Checklist

When implementing serverless security:

- [ ] Input validation at gateway and handler
- [ ] Secrets in Secrets Manager or Parameter Store
- [ ] Per-function IAM roles (least privilege)
- [ ] Token validation with all required checks
- [ ] Sensitive data excluded from logs
- [ ] Dependency vulnerability scanning enabled
- [ ] Audit logging for security events
- [ ] Error messages don't leak internal details

## References

- [OWASP Serverless Top 10](https://owasp.org/www-project-serverless-top-10/)
- [AWS Lambda Security Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/security.html)
- [AWS Well-Architected Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)
