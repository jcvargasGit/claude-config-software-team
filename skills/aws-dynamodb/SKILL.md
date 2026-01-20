---
name: aws-dynamodb
description: Apply AWS DynamoDB best practices including single-table design, access patterns, GSI/LSI design, and capacity management.
---

# AWS DynamoDB Skill

Apply DynamoDB best practices for serverless applications.

## Single-Table Design

### Core Principle

> "Design for access patterns, not for data structure"

Single-table design stores multiple entity types in one table, using carefully crafted partition and sort keys.

### Benefits

| Benefit | Description |
|---------|-------------|
| Reduced latency | Fewer round trips |
| Atomic operations | Transactions across entities |
| Cost efficiency | One table to provision |
| Simplified ops | One table to monitor |

### When to Use

| Use Single Table | Use Multiple Tables |
|------------------|---------------------|
| Related entities queried together | Independent domains |
| Transaction requirements | Different scaling needs |
| Simple access patterns | Complex reporting needs |
| Serverless applications | Team boundaries matter |

## Key Design

### Partition Key (PK)

- Determines data distribution
- Must be highly selective
- Common patterns: `USER#<id>`, `ORDER#<id>`

### Sort Key (SK)

- Enables range queries within partition
- Defines hierarchy: `PROFILE`, `ORDER#<date>`
- Supports begins_with queries

### Key Design Patterns

| Pattern | PK | SK | Use Case |
|---------|----|----|----------|
| Simple lookup | `USER#123` | `PROFILE` | Get user by ID |
| One-to-many | `USER#123` | `ORDER#<date>` | Get user's orders |
| Many-to-many | `ORDER#456` | `PRODUCT#789` | Order line items |
| Adjacency | `ENTITY#123` | `REL#<type>#<id>` | Graph relationships |

## Access Pattern Design

### Process

1. List all access patterns
2. Design keys to support each pattern
3. Add GSIs only when PK queries insufficient
4. Validate with sample queries

### Access Pattern Table

| Access Pattern | Key Condition | Index |
|----------------|---------------|-------|
| Get user by ID | PK=USER#id, SK=PROFILE | Table |
| List user orders | PK=USER#id, SK begins_with ORDER# | Table |
| Get order by ID | PK=ORDER#id | Table |
| Orders by date | PK=USER#id, SK between dates | Table |
| Orders by status | GSI1PK=STATUS#pending | GSI1 |

## Global Secondary Indexes (GSI)

### When to Use GSI

- Query by non-key attribute
- Different access pattern than table key
- Aggregations across partitions

### GSI Design Rules

| Rule | Rationale |
|------|-----------|
| Max 20 GSIs per table | Hard limit |
| Sparse indexes save cost | Only items with GSI keys indexed |
| Project only needed attributes | Reduce storage and RCU |
| Same key can appear in multiple GSIs | Different access patterns |

### GSI Projection Types

| Type | When to Use |
|------|-------------|
| KEYS_ONLY | Lookup IDs, then fetch from table |
| INCLUDE | Frequently accessed attributes |
| ALL | Read-heavy, avoid table fetches |

## Local Secondary Indexes (LSI)

### When to Use LSI

- Same partition key, different sort order
- Strong consistency required
- Must be created at table creation

### LSI vs GSI

| Aspect | LSI | GSI |
|--------|-----|-----|
| Partition key | Same as table | Different |
| Sort key | Different | Different |
| Consistency | Strong available | Eventually consistent only |
| Capacity | Shares with table | Separate |
| Creation | At table creation only | Anytime |

## Query vs Scan

### Always Prefer Query

| Operation | Cost | Use Case |
|-----------|------|----------|
| Query | O(items returned) | Known partition key |
| Scan | O(entire table) | Analytics only, offline |

### Query Optimization

- Use key conditions (not filters) for performance
- Filters applied AFTER read, still consume RCUs
- Use projection expressions to reduce data transfer
- Limit results when possible

### When Scan is Acceptable

- One-time data migration
- Analytics on small tables
- Export to S3 (use parallel scan)
- Never in hot path

## Capacity Modes

### On-Demand Mode

| Pros | Cons |
|------|------|
| No capacity planning | Higher per-request cost |
| Auto-scales instantly | No reserved capacity discounts |
| Pay per request | Less predictable costs |

**Best for**: Variable/unpredictable traffic, new applications

### Provisioned Mode

| Pros | Cons |
|------|------|
| Lower cost at scale | Requires capacity planning |
| Reserved capacity discounts | Throttling if underprovisioned |
| Predictable costs | Waste if overprovisioned |

**Best for**: Predictable traffic, cost optimization

### Auto Scaling

- Set target utilization (70% typical)
- Define min and max capacity
- Responds within minutes
- Not instant (use on-demand for spikes)

## DynamoDB Streams

### Use Cases

| Use Case | Pattern |
|----------|---------|
| Audit logging | Stream to S3/OpenSearch |
| Replication | Stream to another region |
| Aggregations | Update counters on change |
| Notifications | Trigger SNS/SES on change |
| Sync to cache | Invalidate/update Redis |

### Stream View Types

| Type | Contains |
|------|----------|
| KEYS_ONLY | Just the key attributes |
| NEW_IMAGE | Item after modification |
| OLD_IMAGE | Item before modification |
| NEW_AND_OLD_IMAGES | Both (most flexible) |

### Stream Processing

- Lambda triggers for event-driven
- Kinesis Data Streams for high volume
- Exactly-once processing with idempotency
- Handle partial batch failures

## Transaction Patterns

### When to Use Transactions

- Multi-item atomic writes
- Conditional writes across items
- Read-then-write patterns

### Transaction Limits

| Limit | Value |
|-------|-------|
| Items per transaction | 100 |
| Size per transaction | 4 MB |
| Operations | Put, Update, Delete, ConditionCheck |

### Transaction Patterns

| Pattern | Use Case |
|---------|----------|
| Transfer | Debit A, Credit B atomically |
| Inventory | Reserve stock, create order |
| Idempotency | Check token, write result |

## TTL for Expiration

### Use Cases

- Session data
- Temporary tokens
- Event logs retention
- Cache entries

### TTL Best Practices

| Practice | Rationale |
|----------|-----------|
| Use epoch seconds | DynamoDB expects Unix timestamp |
| Delete within 48h | Not immediate, background process |
| Don't rely for security | Use explicit validation too |
| Index TTL attribute | Query soon-to-expire items |

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| ProvisionedThroughputExceeded | Over capacity | Retry with backoff, increase capacity |
| ConditionalCheckFailed | Condition not met | Handle as business logic |
| TransactionConflict | Concurrent modification | Retry with backoff |
| ValidationException | Invalid request | Fix request structure |

### Retry Strategy

- Exponential backoff for throttling
- Jitter to prevent thundering herd
- Max retries with circuit breaker
- Log throttling for capacity alerts

## Data Modeling Patterns

### One-to-Many

```
PK              SK              Data
USER#123        PROFILE         {name, email}
USER#123        ORDER#2024-01   {total, status}
USER#123        ORDER#2024-02   {total, status}
```

### Many-to-Many (Adjacency List)

```
PK              SK              Data
USER#123        GROUP#456       {joinDate}
GROUP#456       USER#123        {role}
GROUP#456       USER#789        {role}
```

### Hierarchical Data

```
PK              SK                    Data
ORG#1           METADATA              {name}
ORG#1           DEPT#sales            {budget}
ORG#1           DEPT#sales#TEAM#a     {lead}
```

## Quality Checklist

When designing DynamoDB schemas:

- [ ] All access patterns documented
- [ ] Each pattern has efficient key design
- [ ] GSIs only for necessary access patterns
- [ ] Query used instead of Scan
- [ ] Capacity mode appropriate for workload
- [ ] TTL for expiring data
- [ ] Error handling with retries
- [ ] Monitoring for throttling

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Scan in hot path | High latency, cost | Design keys for Query |
| Large items | 400KB limit, slow | Split into multiple items |
| Hot partition | Throttling | Distribute with write sharding |
| Over-indexing | Cost, complexity | Only indexes for access patterns |
| Relational thinking | Poor performance | Embrace denormalization |

## References

- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [Single-Table Design by Alex DeBrie](https://www.alexdebrie.com/posts/dynamodb-single-table/)
- [DynamoDB Book](https://www.dynamodbbook.com/)
