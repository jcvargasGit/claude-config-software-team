---
name: aws-iam
description: Apply AWS IAM best practices including least privilege, execution role design, and policy patterns for serverless applications.
---

# AWS IAM Skill

Apply IAM best practices for serverless and cloud applications.

## Least Privilege Principle

### Core Concept

> "Grant only the permissions required to perform a task"

Every function, service, and user should have minimal permissions needed for their specific purpose.

### Implementation Steps

1. Start with no permissions
2. Add specific actions needed
3. Scope to specific resources
4. Add conditions where possible
5. Review and remove unused

## Execution Role Design

### One Role Per Function

| Approach | Blast Radius | Management |
|----------|-------------|------------|
| Role per function | Minimal | More roles |
| Role per service | Medium | Balanced |
| Shared role | Maximum | Fewer roles |

**Recommendation**: Start with role per function, consolidate if management burden is high.

### Role Structure

```yaml
# Execution role components
- AssumeRolePolicy: Who can assume (Lambda service)
- ManagedPolicies: AWS-managed (BasicExecutionRole)
- InlinePolicy: Custom permissions specific to function
```

### Lambda Execution Role Minimum

Every Lambda needs at minimum:

| Permission | Purpose |
|------------|---------|
| logs:CreateLogGroup | Create log group |
| logs:CreateLogStream | Create log stream |
| logs:PutLogEvents | Write logs |

## Policy Types

### Identity-Based Policies

Attached to IAM users, groups, or roles.

| Type | Use Case |
|------|----------|
| AWS Managed | Common use cases (ReadOnlyAccess) |
| Customer Managed | Reusable custom policies |
| Inline | Single-use, specific to one entity |

### Resource-Based Policies

Attached to resources, define who can access.

| Service | Resource Policy |
|---------|-----------------|
| S3 | Bucket policy |
| Lambda | Function policy |
| SQS | Queue policy |
| KMS | Key policy |
| API Gateway | Resource policy |

### When to Use Each

| Scenario | Policy Type |
|----------|-------------|
| Lambda accessing DynamoDB | Identity-based on role |
| S3 bucket accessed by multiple accounts | Resource-based |
| Lambda invoked by API Gateway | Resource-based |
| Cross-account access | Both needed |

## Cross-Service Permission Patterns

### Lambda to DynamoDB

```yaml
Effect: Allow
Action:
  - dynamodb:GetItem
  - dynamodb:PutItem
  - dynamodb:Query
Resource:
  - arn:aws:dynamodb:region:account:table/TableName
  - arn:aws:dynamodb:region:account:table/TableName/index/*
```

### Lambda to S3

```yaml
Effect: Allow
Action:
  - s3:GetObject
  - s3:PutObject
Resource: arn:aws:s3:::bucket-name/prefix/*
```

### Lambda to Secrets Manager

```yaml
Effect: Allow
Action:
  - secretsmanager:GetSecretValue
Resource: arn:aws:secretsmanager:region:account:secret:secret-name-*
```

### Lambda to SQS

```yaml
Effect: Allow
Action:
  - sqs:ReceiveMessage
  - sqs:DeleteMessage
  - sqs:GetQueueAttributes
Resource: arn:aws:sqs:region:account:queue-name
```

## Condition Keys

### Common Conditions

| Condition Key | Use Case |
|---------------|----------|
| aws:SourceArn | Restrict to specific source |
| aws:SourceAccount | Restrict to account |
| aws:RequestedRegion | Restrict to regions |
| aws:PrincipalTag | Tag-based access |
| aws:ResourceTag | Resource tag matching |

### IP Restriction

```yaml
Condition:
  IpAddress:
    aws:SourceIp:
      - 10.0.0.0/8
```

### Time-Based Restriction

```yaml
Condition:
  DateGreaterThan:
    aws:CurrentTime: "2024-01-01T00:00:00Z"
  DateLessThan:
    aws:CurrentTime: "2024-12-31T23:59:59Z"
```

### MFA Requirement

```yaml
Condition:
  Bool:
    aws:MultiFactorAuthPresent: "true"
```

## SAM/CloudFormation Policy Templates

### SAM Managed Policies

SAM provides pre-built policy templates:

| Policy | Permissions |
|--------|------------|
| DynamoDBCrudPolicy | CRUD on specific table |
| S3ReadPolicy | Read from specific bucket |
| SQSPollerPolicy | Poll specific queue |
| SNSPublishMessagePolicy | Publish to topic |
| SecretsManagerReadPolicy | Read specific secret |

### SAM Policy Usage

```yaml
Resources:
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref MyTable
        - S3ReadPolicy:
            BucketName: !Ref MyBucket
```

### Custom Inline Policy

```yaml
Policies:
  - Statement:
      - Effect: Allow
        Action:
          - cognito-idp:AdminGetUser
        Resource: !GetAtt UserPool.Arn
```

## Permission Boundaries

### Purpose

Set maximum permissions that identity-based policies can grant.

### Use Cases

| Use Case | Benefit |
|----------|---------|
| Delegated admin | Limit what admins can grant |
| Developer sandboxes | Prevent privilege escalation |
| Multi-tenant | Isolate tenant permissions |

### How It Works

Effective permissions = Identity policy ∩ Permission boundary

## Resource ARN Patterns

### ARN Structure

```
arn:partition:service:region:account:resource-type/resource-id
```

### Wildcard Usage

| Pattern | Meaning |
|---------|---------|
| `*` | All resources (avoid) |
| `arn:aws:s3:::bucket/*` | All objects in bucket |
| `table/MyTable` | Specific table |
| `table/MyTable/index/*` | All indexes on table |

### Scoping Examples

```yaml
# Too broad - avoid
Resource: "*"

# Better - specific table
Resource: "arn:aws:dynamodb:us-east-1:123456789:table/users"

# Best - with environment variable
Resource: !Sub "arn:aws:dynamodb:${AWS::Region}:${AWS::AccountId}:table/${TableName}"
```

## Common Patterns

### Read-Only Access

```yaml
Effect: Allow
Action:
  - dynamodb:GetItem
  - dynamodb:Query
  - dynamodb:Scan
Resource: !GetAtt Table.Arn
```

### Write Access (No Delete)

```yaml
Effect: Allow
Action:
  - dynamodb:PutItem
  - dynamodb:UpdateItem
Resource: !GetAtt Table.Arn
```

### Admin Access (Specific Table)

```yaml
Effect: Allow
Action:
  - dynamodb:*
Resource:
  - !GetAtt Table.Arn
  - !Sub "${Table.Arn}/index/*"
```

## Cross-Account Access

### Trust Policy (Trusting Account)

```yaml
AssumeRolePolicyDocument:
  Statement:
    - Effect: Allow
      Principal:
        AWS: arn:aws:iam::OTHER-ACCOUNT:role/RoleName
      Action: sts:AssumeRole
```

### Assuming Role (Calling Account)

```yaml
Effect: Allow
Action: sts:AssumeRole
Resource: arn:aws:iam::TARGET-ACCOUNT:role/RoleName
```

## Service-Linked Roles

### What They Are

Pre-defined roles created by AWS services for their operation.

### Common Service-Linked Roles

| Service | Role Purpose |
|---------|--------------|
| Lambda | VPC ENI management |
| API Gateway | CloudWatch logging |
| DynamoDB | Auto scaling |
| RDS | Enhanced monitoring |

## Troubleshooting

### Access Denied Analysis

1. Check IAM policy simulator
2. Review CloudTrail for denied actions
3. Verify resource ARN matches
4. Check condition key values
5. Verify trust policy (for roles)

### Common Issues

| Error | Likely Cause |
|-------|--------------|
| AccessDenied | Missing permission |
| MalformedPolicyDocument | Syntax error |
| InvalidParameterValue | Wrong ARN format |
| EntityAlreadyExists | Duplicate name |

### IAM Policy Simulator

Test policies before deployment:

1. Select principal (user/role)
2. Select action to test
3. Provide resource ARN
4. Check simulation result

## Quality Checklist

When designing IAM policies:

- [ ] Specific actions (no wildcards)
- [ ] Specific resources (full ARNs)
- [ ] Conditions where applicable
- [ ] Per-function roles (when practical)
- [ ] Resource-based policies for cross-service
- [ ] Permission boundaries for delegation
- [ ] Regular access reviews
- [ ] CloudTrail enabled for auditing

## Anti-Patterns

| Anti-Pattern | Risk | Solution |
|--------------|------|----------|
| `Action: "*"` | Full access | List specific actions |
| `Resource: "*"` | All resources | Use specific ARNs |
| Shared admin role | Blast radius | Per-service roles |
| Long-lived credentials | Compromise | Use roles, rotate |
| Inline policies everywhere | Hard to audit | Customer managed policies |

## References

- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [SAM Policy Templates](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-policy-templates.html)
- [IAM Policy Simulator](https://policysim.aws.amazon.com/)
