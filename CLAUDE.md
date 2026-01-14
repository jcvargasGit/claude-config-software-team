# CLAUDE.md

This file provides global guidance to Claude Code on how to use agents and skills across all projects.

## Configuration Layers

Claude Code uses two configuration layers:

### Global Configuration (~/.claude)

Generic agents and skills that work across any project:

| Type | Examples |
|------|----------|
| **Agents** | backend-developer, frontend-engineer, test-engineer, solution-architect, product-manager, devops-engineer |
| **Language Skills** | lang-golang, lang-typescript, lang-python, lang-javascript, lang-nodejs |
| **Frontend Skills** | frontend-html, frontend-css, frontend-react |
| **Cloud Skills** | cloud-aws, cloud-cloudformation, cloud-sam |
| **DevOps Skills** | devops-terraform, devops-github-actions |
| **Architecture Skills** | arch-hexagonal, arch-cloud |
| **Testing Skills** | testing-serverless |
| **Other Skills** | clean-code, observability |
| **Commands** | commit, review-pr |

### Project-Specific Configuration (project/.claude)

Domain expertise and project-specific settings:

| Type | Examples |
|------|----------|
| **Domain Agents** | pm-career-platform (ATS expertise), pm-ecommerce (e-commerce domain) |
| **Project Docs** | PROJECT.md (structure, conventions, architecture) |
| **Personas** | User personas specific to the product |
| **Permissions** | settings.local.json |

### How They Work Together

1. **Global agent in ~/.claude**: Provides role and skills
2. **Domain agent in project/.claude**: Adds domain expertise
3. **Both are available**: User chooses based on context

**Example:**
- `product-manager` → "Write user stories for a login feature"
- `pm-career-platform` → "Write stories with ATS optimization in mind"

## Agent Usage Policy

### CRITICAL: Always Use Agents for Code Implementation

When writing or modifying code, you MUST use the Task tool to invoke the appropriate agent:

- **Frontend code** → frontend-engineer agent
- **Backend code** → backend-developer agent
- **Infrastructure** → devops-engineer agent
- **Test code** → test-engineer agent
- **Architecture design** → solution-architect agent
- **Specifications** → product-manager agent

### Process Requirements

1. **Do NOT claim you're using an agent** - Actually invoke it with the Task tool
2. **Validation check**: If you see excessive comments in code you wrote, you bypassed the agent system
3. **Skills are only loaded when agents are invoked** - Base LLM behavior includes verbose comments

### Agent Selection Guide

| Task Type | Agent | Invocation |
|-----------|-------|------------|
| React/Next.js components | frontend-engineer | Task tool with subagent_type: "frontend-engineer" |
| Go/Lambda functions | backend-developer | Task tool with subagent_type: "backend-developer" |
| SAM/Terraform | devops-engineer | Task tool with subagent_type: "devops-engineer" |
| Test design/implementation | test-engineer | Task tool with subagent_type: "test-engineer" |
| Design decisions (NO code) | solution-architect | Task tool with subagent_type: "solution-architect" |
| User stories, PRDs | product-manager | Task tool with subagent_type: "product-manager" |

### Agent File Extensions and Contexts

Select agents based on file types and project context:

**Decision-Making Rules:**
1. **Primary responsibility wins** - Choose the agent whose primary role matches the task intent
2. **Application code vs Infrastructure** - backend-developer writes app code, devops-engineer manages infrastructure
3. **Multi-agent tasks** - Break into separate tasks and invoke appropriate agents sequentially
4. **When unclear** - Default to the agent closest to the code's runtime purpose:
   - If it runs as application logic → backend-developer
   - If it provisions/deploys → devops-engineer
   - If it tests functionality → test-engineer

#### backend-developer

**File Extensions:**
- `.go` - Go source files
- `.py` - Python source files
- `.js`, `.mjs`, `.cjs` - Node.js JavaScript
- `.ts` - TypeScript for Node.js/backend
- `.yaml`, `.yml` - SAM templates when writing application code (Lambda handlers, API definitions)
- `.json` - Package manifests (package.json), SAM/CloudFormation when defining application resources
- `go.mod`, `go.sum` - Go dependencies
- `requirements.txt`, `pyproject.toml`, `poetry.lock` - Python dependencies
- `package.json`, `package-lock.json` - Node.js dependencies

**Project Contexts:**
- REST API development
- GraphQL servers
- Lambda function implementation (handler code)
- Microservices (application logic)
- CLI tools
- Database schema and migrations
- API integrations
- Business logic implementation

**NOT responsible for:**
- CI/CD pipeline definitions
- Infrastructure provisioning (pure Terraform modules)
- Deployment scripts

#### frontend-engineer

**File Extensions:**
- `.tsx`, `.jsx` - React components
- `.ts`, `.js` - Frontend TypeScript/JavaScript
- `.css`, `.scss`, `.sass` - Stylesheets
- `.html` - HTML templates
- `.json` - Frontend configs (tsconfig.json, package.json)
- `.svg` - SVG assets
- `.module.css` - CSS modules

**Project Contexts:**
- React applications
- Next.js applications
- Single Page Applications (SPA)
- UI component libraries
- Frontend state management
- Client-side routing
- Web forms and validation

#### test-engineer

**File Extensions:**
- `.test.ts`, `.test.js` - Jest/Vitest tests
- `.spec.ts`, `.spec.js` - Spec files
- `.test.go` - Go tests
- `_test.py` - Python tests (pytest)
- `.integration.test.ts` - Integration tests
- `.e2e.test.ts` - End-to-end tests

**Project Contexts:**
- Unit testing
- Integration testing against real services (AWS, databases)
- API contract testing
- Component testing (React Testing Library)
- Serverless function testing
- Test infrastructure setup

#### devops-engineer

**File Extensions:**
- `.tf`, `.tfvars` - Terraform infrastructure modules and configurations
- `.yaml`, `.yml` - GitHub Actions workflows, CI/CD pipelines, deployment configs
- `Dockerfile`, `.dockerignore` - Container definitions
- `.sh` - Deployment and automation scripts
- `buildspec.yml`, `cloudbuild.yaml` - Build pipeline definitions
- `.json` - CloudFormation templates for infrastructure
- `Makefile` - Build and deployment automation
- `.env.example`, `.env.template` - Environment configuration templates

**Project Contexts:**
- CI/CD pipeline setup and maintenance
- Infrastructure provisioning and management
- Multi-environment deployment strategies
- Container orchestration and registry management
- Build automation and optimization
- Infrastructure monitoring and alerting setup
- Secrets management and rotation

**NOT responsible for:**
- Application code (Lambda handlers, API routes)
- Business logic implementation
- Database queries and ORM models

#### solution-architect

**File Extensions:**
- `.md` - Architecture Decision Records (ADRs)
- `.drawio`, `.puml` - Diagrams
- Design documents (any format)

**Project Contexts:**
- System design and architecture
- Technology selection and trade-offs
- Scalability and performance planning
- Security architecture
- Cost optimization
- Migration strategies
- Architecture reviews (NO implementation)

#### product-manager

**File Extensions:**
- `.md` - User stories, PRDs, specifications, ADRs (when focused on requirements)
- `.txt` - Requirements documents
- `.yaml`, `.yml` - OpenAPI/Swagger specifications
- `.json` - API schemas and contracts

**Project Contexts:**
- Product requirements documentation
- User story writing with Given/When/Then format
- Acceptance criteria definition
- API specification and contract design
- Feature planning and roadmapping
- Stakeholder communication
- Success metrics definition

**NOT responsible for:**
- Writing implementation code
- Technical architecture decisions
- Infrastructure design

### Common Scenarios and Agent Selection

**Example 1: SAM template with Lambda function**
- **File:** `template.yaml` defining Lambda, API Gateway, DynamoDB
- **Task:** "Add a new Lambda function for user registration"
- **Agent:** backend-developer (application resource definition)

**Example 2: SAM template infrastructure setup**
- **File:** `template.yaml` defining VPC, subnets, security groups
- **Task:** "Set up VPC and networking for the application"
- **Agent:** devops-engineer (infrastructure provisioning)

**Example 3: Terraform with application resources**
- **File:** `lambda.tf` defining Lambda functions and their configuration
- **Task:** "Add error handling to Lambda function definition"
- **Agent:** backend-developer (application configuration)

**Example 4: Terraform for infrastructure**
- **File:** `vpc.tf`, `networking.tf`
- **Task:** "Create multi-AZ networking infrastructure"
- **Agent:** devops-engineer (infrastructure setup)

**Example 5: GitHub Actions workflow**
- **File:** `.github/workflows/deploy.yml`
- **Task:** "Add deployment pipeline for staging environment"
- **Agent:** devops-engineer (CI/CD)

**Example 6: Makefile for build**
- **File:** `Makefile`
- **Task:** "Add commands to build and deploy the application"
- **Agent:** devops-engineer (build automation)

**Example 7: Package.json scripts**
- **File:** `package.json`
- **Task:** "Add development scripts and dependencies"
- **Agent:** backend-developer or frontend-engineer (based on project type)

**Example 8: Full-stack feature**
- **Task:** "Implement user authentication with UI and API"
- **Approach:**
  1. product-manager → Define acceptance criteria
  2. backend-developer → Implement auth API
  3. frontend-engineer → Implement auth UI
  4. test-engineer → Write integration tests

### Red Flags (Agent NOT Used)

- ❌ Extensive JSDoc comments on every function
- ❌ Inline comments explaining obvious code
- ❌ Example usage comments in implementation files
- ❌ "This function does X" comments where name already says X

### Clean Code (Agent WAS Used)

- ✅ Descriptive function and variable names
- ✅ Small, focused functions
- ✅ Type safety from schemas (Zod, TypeScript)
- ✅ Comments only for non-obvious business logic
