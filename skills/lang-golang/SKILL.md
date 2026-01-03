---
name: lang-golang
description: Apply Go best practices, idiomatic patterns, and language-specific expertise when writing or reviewing Go code.
---

# Go Development Skill

Apply these Go-specific patterns and practices when working with Go code.

## Idiomatic Go

### Code Style
- Follow [Effective Go](https://go.dev/doc/effective_go) principles
- Use `gofmt` / `goimports` formatting
- Keep names short but descriptive (`i` for index, `r` for reader, `ctx` for context)
- Acronyms should be all caps (`HTTP`, `ID`, `URL`)
- Unexported names start lowercase, exported start uppercase
- More than 2 parameters: use structs (Go convention)

### Error Handling
```go
// Wrap errors with context (Go 1.13+)
if err != nil {
    return fmt.Errorf("failed to process order %s: %w", orderID, err)
}

// Check for specific errors
if errors.Is(err, sql.ErrNoRows) {
    return nil, ErrNotFound
}

// Type assert errors
var validationErr *ValidationError
if errors.As(err, &validationErr) {
    // handle validation error
}
```

### Concurrency Patterns
```go
// Always pass context for cancellation
func DoWork(ctx context.Context) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    case result := <-workChan:
        return process(result)
    }
}

// Use errgroup for concurrent operations
g, ctx := errgroup.WithContext(ctx)
for _, item := range items {
    item := item // capture loop variable
    g.Go(func() error {
        return processItem(ctx, item)
    })
}
if err := g.Wait(); err != nil {
    return err
}

// Protect shared state with mutex
type Counter struct {
    mu    sync.Mutex
    count int
}

func (c *Counter) Inc() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}
```

### Interface Design
```go
// Define small interfaces at point of use
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Accept interfaces, return structs
func NewService(repo Repository) *Service {
    return &Service{repo: repo}
}

// Use interface{} sparingly, prefer generics in Go 1.18+
func Map[T, U any](items []T, fn func(T) U) []U {
    result := make([]U, len(items))
    for i, item := range items {
        result[i] = fn(item)
    }
    return result
}
```

## Project Structure (Hexagonal)

Go implementation of hexagonal architecture. See `arch-hexagonal` skill for concepts.

```
app/
├── cmd/
│   ├── api/
│   │   └── main.go           # HTTP API entrypoint
│   └── worker/
│       └── main.go           # Event worker entrypoint
├── internal/
│   ├── domain/               # Core business logic (no dependencies)
│   │   ├── user/
│   │   │   ├── entity.go     # User entity
│   │   │   ├── repository.go # Repository interface (output port)
│   │   │   └── service.go    # Domain service
│   │   └── order/
│   │       ├── entity.go
│   │       ├── repository.go
│   │       └── service.go
│   ├── application/          # Use cases / Application services
│   │   ├── dto/              # Input/Output DTOs
│   │   │   └── user.go
│   │   └── usecase/          # One file per use case
│   │       ├── create_user.go
│   │       └── get_user.go
│   ├── adapter/
│   │   ├── input/            # Driving adapters
│   │   │   ├── http/         # HTTP handlers
│   │   │   │   ├── handler.go
│   │   │   │   ├── router.go
│   │   │   │   └── middleware.go
│   │   │   └── lambda/       # Lambda handlers
│   │   │       └── handler.go
│   │   └── output/           # Driven adapters
│   │       ├── persistence/  # Database implementations
│   │       │   ├── dynamodb/
│   │       │   │   └── user_repository.go
│   │       │   └── postgres/
│   │       │       └── user_repository.go
│   │       └── gateway/      # External API clients
│   │           └── payment/
│   │               └── stripe.go
│   └── config/               # Configuration loading
│       └── config.go
├── pkg/                      # Shared public libraries (if any)
├── go.mod
├── go.sum
└── Makefile
```

### Layer Rules

```go
// domain/user/repository.go - Output port (interface in domain)
type Repository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// domain/user/entity.go - Pure domain, no external imports
type User struct {
    ID        string
    Email     string
    CreatedAt time.Time
}

func NewUser(email string) (*User, error) {
    if email == "" {
        return nil, ErrInvalidEmail
    }
    return &User{
        ID:        uuid.NewString(),
        Email:     email,
        CreatedAt: time.Now(),
    }, nil
}

// application/usecase/create_user.go - Use case with injected port
type CreateUserUseCase struct {
    repo user.Repository  // depends on interface, not implementation
}

func (uc *CreateUserUseCase) Execute(ctx context.Context, input dto.CreateUserInput) (*dto.UserOutput, error) {
    u, err := user.NewUser(input.Email)
    if err != nil {
        return nil, err
    }
    if err := uc.repo.Save(ctx, u); err != nil {
        return nil, err
    }
    return &dto.UserOutput{ID: u.ID, Email: u.Email}, nil
}

// adapter/output/persistence/dynamodb/user_repository.go - Driven adapter
type UserRepository struct {
    client *dynamodb.Client
    table  string
}

func (r *UserRepository) FindByID(ctx context.Context, id string) (*user.User, error) {
    // Implementation using DynamoDB client
}

// cmd/api/main.go - Wire everything together
func main() {
    // 1. Create driven adapters
    userRepo := dynamodb.NewUserRepository(client, tableName)

    // 2. Create use cases with output ports
    createUser := usecase.NewCreateUserUseCase(userRepo)

    // 3. Create driving adapters with use cases
    handler := http.NewHandler(createUser)

    // 4. Start
    router := http.NewRouter(handler)
    router.ListenAndServe(":8080")
}
```

## Testing

```go
// Table-driven tests
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -2, -3},
        {"zero", 0, 0, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, result, tt.expected)
            }
        })
    }
}

// Use testify for assertions
func TestService(t *testing.T) {
    assert := assert.New(t)
    require := require.New(t)

    result, err := service.Process(input)
    require.NoError(err)
    assert.Equal(expected, result)
}

// Mock interfaces with gomock or manual mocks
type mockRepository struct {
    items map[string]Item
}

func (m *mockRepository) Get(id string) (Item, error) {
    item, ok := m.items[id]
    if !ok {
        return Item{}, ErrNotFound
    }
    return item, nil
}
```

## Performance

### Memory Optimization
```go
// Pre-allocate slices when size is known
items := make([]Item, 0, len(input))

// Use sync.Pool for frequently allocated objects
var bufferPool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

buf := bufferPool.Get().(*bytes.Buffer)
defer bufferPool.Put(buf)
buf.Reset()

// Avoid string concatenation in loops
var sb strings.Builder
for _, s := range items {
    sb.WriteString(s)
}
result := sb.String()
```

### Profiling
```bash
# CPU profiling
go test -cpuprofile=cpu.prof -bench=.
go tool pprof cpu.prof

# Memory profiling
go test -memprofile=mem.prof -bench=.
go tool pprof mem.prof

# Benchmarking
func BenchmarkProcess(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Process(input)
    }
}
```

## Common Libraries

| Purpose | Library |
|---------|---------|
| Logging | `zerolog`, `zap`, `slog` (std) |
| HTTP Router | `chi`, `gin`, `echo` |
| Validation | `go-playground/validator` |
| Testing | `testify`, `gomock` |
| Config | `viper`, `envconfig` |
| AWS SDK | `aws-sdk-go-v2` |
| Database | `sqlx`, `pgx`, `gorm` |

## Lambda Patterns

```go
// Handler structure
func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
    // Initialize outside handler for connection reuse
    // Parse request
    // Call business logic
    // Return response with proper status codes
}

// Cold start optimization
var (
    db     *dynamodb.Client
    once   sync.Once
    initErr error
)

func getDB() (*dynamodb.Client, error) {
    once.Do(func() {
        cfg, err := config.LoadDefaultConfig(context.Background())
        if err != nil {
            initErr = err
            return
        }
        db = dynamodb.NewFromConfig(cfg)
    })
    return db, initErr
}
```

## Quality Checklist

When writing Go code, verify:
- [ ] Errors are wrapped with context
- [ ] Context is propagated through call chain
- [ ] Resources are closed with defer
- [ ] Goroutines have proper cleanup (no leaks)
- [ ] Shared state is protected with mutex or channels
- [ ] Exported functions have doc comments
- [ ] Tests cover error paths
- [ ] No hardcoded configuration
