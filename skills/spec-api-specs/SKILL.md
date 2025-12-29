---
name: spec-api-specs
description: Design API specifications using OpenAPI/REST conventions with clear contracts and error handling.
---

# API Specification Skill

Apply these patterns when designing API specifications.

## OpenAPI Structure

```yaml
openapi: 3.0.3
info:
  title: Service Name API
  version: 1.0.0
  description: Brief description of the API

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api.staging.example.com/v1
    description: Staging

paths:
  /resources:
    get:
      summary: List resources
      # ...

components:
  schemas:
    # Data models
  securitySchemes:
    # Authentication
```

## Endpoint Design

### URL Conventions

```
GET    /users          # List users
POST   /users          # Create user
GET    /users/{id}     # Get user
PUT    /users/{id}     # Replace user
PATCH  /users/{id}     # Update user fields
DELETE /users/{id}     # Delete user

GET    /users/{id}/orders    # List user's orders (nested resource)
```

### Naming Rules
- Use plural nouns for collections (`/users` not `/user`)
- Use kebab-case for multi-word (`/user-profiles`)
- Use path parameters for identifiers (`/users/{userId}`)
- Use query parameters for filtering (`/users?status=active`)

## Request/Response Design

### Request Body

```yaml
requestBody:
  required: true
  content:
    application/json:
      schema:
        type: object
        required:
          - email
          - password
        properties:
          email:
            type: string
            format: email
            example: user@example.com
          password:
            type: string
            minLength: 8
            example: "securePassword123"
          name:
            type: string
            maxLength: 100
```

### Response Body

```yaml
responses:
  '200':
    description: Successful response
    content:
      application/json:
        schema:
          type: object
          properties:
            id:
              type: string
              format: uuid
            email:
              type: string
            createdAt:
              type: string
              format: date-time
```

### Pagination

```yaml
# Request
GET /users?page=2&limit=20

# Response
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### Filtering & Sorting

```yaml
# Filtering
GET /orders?status=pending&createdAfter=2025-01-01

# Sorting
GET /products?sort=price:asc,name:desc
```

## HTTP Status Codes

### Success

| Code | Usage |
|------|-------|
| 200 | OK - General success |
| 201 | Created - Resource created |
| 204 | No Content - Success with no body (DELETE) |

### Client Errors

| Code | Usage |
|------|-------|
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource state conflict |
| 422 | Unprocessable Entity - Validation failed |
| 429 | Too Many Requests - Rate limited |

### Server Errors

| Code | Usage |
|------|-------|
| 500 | Internal Server Error |
| 502 | Bad Gateway |
| 503 | Service Unavailable |
| 504 | Gateway Timeout |

## Error Handling

### Standard Error Format

```yaml
components:
  schemas:
    Error:
      type: object
      required:
        - code
        - message
      properties:
        code:
          type: string
          description: Machine-readable error code
          example: VALIDATION_ERROR
        message:
          type: string
          description: Human-readable message
          example: "Validation failed"
        details:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              message:
                type: string
          example:
            - field: email
              message: "Invalid email format"
            - field: password
              message: "Must be at least 8 characters"
```

### Error Codes

Define consistent error codes:

```yaml
# Error codes by category
AUTH_001: Invalid credentials
AUTH_002: Token expired
AUTH_003: Insufficient permissions

VALIDATION_001: Required field missing
VALIDATION_002: Invalid format
VALIDATION_003: Value out of range

RESOURCE_001: Not found
RESOURCE_002: Already exists
RESOURCE_003: State conflict
```

## Authentication

### Bearer Token

```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - bearerAuth: []
```

### API Key

```yaml
components:
  securitySchemes:
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
```

## Versioning

### URL Versioning (Recommended)
```
https://api.example.com/v1/users
https://api.example.com/v2/users
```

### Header Versioning
```
Accept: application/vnd.api+json; version=1
```

## Rate Limiting

Document rate limits in responses:

```yaml
headers:
  X-RateLimit-Limit:
    description: Requests allowed per window
    schema:
      type: integer
  X-RateLimit-Remaining:
    description: Requests remaining in window
    schema:
      type: integer
  X-RateLimit-Reset:
    description: Unix timestamp when window resets
    schema:
      type: integer
```

## Best Practices

### Consistency
- Same patterns across all endpoints
- Consistent naming conventions
- Uniform error format

### Documentation
- Every endpoint has a summary
- All parameters documented
- Examples for request/response bodies
- Error cases documented

### Security
- Use HTTPS only
- Validate all input
- Return minimal data (no over-fetching)
- Implement rate limiting

## Template

```yaml
openapi: 3.0.3
info:
  title: [Service Name] API
  version: 1.0.0
  description: |
    [Description of what this API does]

servers:
  - url: https://api.example.com/v1

paths:
  /resource:
    get:
      summary: List resources
      operationId: listResources
      tags:
        - Resources
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ResourceList'
        '401':
          $ref: '#/components/responses/Unauthorized'

components:
  schemas:
    Resource:
      type: object
      properties:
        id:
          type: string
        # ... properties

  responses:
    Unauthorized:
      description: Authentication required
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer

security:
  - bearerAuth: []
```
