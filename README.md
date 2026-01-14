# Claude Code Configuration

This repository contains reusable Claude Code configuration files that get symlinked to `~/.claude` for use across all your projects. It includes skills, agents, and commands that define specialized AI behaviors for software development workflows.

Feel free to use, adapt, and contribute to these configurations!

## Quick Start

```bash
./setup.sh  # Symlinks configs to ~/.claude
claude /config  # Verify configuration
```

## What's Included

This configuration repository provides:

- **Skills**: Specialized knowledge modules for languages, frameworks, cloud platforms, and architecture patterns
- **Agents**: Role-based AI assistants (backend-developer, frontend-engineer, solution-architect, etc.)
- **Commands**: Custom slash commands like `/commit` and `/review-pr`

Once installed, these configurations are available globally across all your Claude Code projects.

## Repository Structure

```
skills/           # Specialized knowledge modules (SKILL.md files)
  lang-*          # Language skills: golang, typescript, javascript, python, nodejs
  frontend-*      # Frontend: html, css, react
  cloud-*         # Cloud: aws, cloudformation, sam
  devops-*        # DevOps: terraform, github-actions
  spec-*          # Specs: user-stories, acceptance-criteria, prd, api-specs
  arch-*          # Architecture: cloud, hexagonal
  observability/  # Logging, tracing, error tracking
  testing-serverless/  # Serverless testing patterns
  clean-code/     # Clean Code principles

agents/           # Agent definitions with skill compositions
  solution-architect.md   # Design/advisory only, NO code
  backend-developer.md    # Backend implementation
  frontend-engineer.md    # Frontend implementation
  test-engineer.md        # Testing
  product-manager.md      # Spec-driven development
  devops-engineer.md      # CI/CD, infrastructure

commands/         # Custom slash commands
  commit.md       # /commit - semantic commit messages
  review-pr.md    # /review-pr - comprehensive PR review
```

## Skills by Category

| Prefix | Category | Skills |
|--------|----------|--------|
| `lang-` | Languages | golang, typescript, javascript, python, nodejs |
| `frontend-` | Frontend | html, css, react |
| `cloud-` | Cloud Providers | aws, cloudformation, sam |
| `devops-` | DevOps | terraform, github-actions |
| `spec-` | Specifications | user-stories, acceptance-criteria, prd, api-specs |
| `arch-` | Architecture | cloud, hexagonal |
| (none) | General | clean-code, observability, testing-serverless |

## Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `solution-architect` | Design, trade-offs, decisions | Architecture design, system reviews, technology selection. Does NOT write code. |
| `backend-developer` | Backend implementation | API development, Lambda functions, infrastructure, CI/CD. Writes code. |
| `frontend-engineer` | Frontend implementation | React components, UI features, frontend tests. Writes code. |
| `test-engineer` | Testing strategy & implementation | Test design, integration tests, serverless testing. Writes tests. |
| `product-manager` | Spec-driven development | User stories, PRDs, acceptance criteria. Does NOT write code. |
| `devops-engineer` | CI/CD & infrastructure | Pipelines, deployments, IaC. Writes infrastructure code. |

### Agent Skills

| Agent | Skills |
|-------|--------|
| `solution-architect` | arch-cloud, arch-hexagonal, spec-acceptance-criteria, spec-api-specs, cloud-aws, clean-code |
| `backend-developer` | clean-code, arch-cloud, arch-hexagonal, lang-golang, lang-python, lang-nodejs, devops-terraform, devops-github-actions, cloud-cloudformation, cloud-sam, observability, testing-serverless |
| `frontend-engineer` | clean-code, lang-typescript, lang-javascript, frontend-html, frontend-css, frontend-react, spec-acceptance-criteria |
| `test-engineer` | clean-code, testing-serverless, lang-golang, lang-typescript, lang-python, cloud-aws |
| `product-manager` | spec-user-stories, spec-acceptance-criteria, spec-prd, spec-api-specs |
| `devops-engineer` | devops-terraform, devops-github-actions, cloud-cloudformation, cloud-sam, cloud-aws, observability |

## Commands

| Command | Description |
|---------|-------------|
| `/commit` | Generate semantic commit message and commit staged changes |
| `/review-pr` | Comprehensive PR review with intelligent agent selection |

## File Formats

### Skills (`skills/*/SKILL.md`)

```yaml
---
name: skill-name
description: When to apply this skill
---
# Content with patterns, examples, checklists
```

Skills define specialized knowledge that agents can use. Each skill is a standalone module in its own directory.

### Agents (`agents/*.md`)

```yaml
---
name: agent-name
description: When to use this agent
model: opus
skills:
  - skill-1
  - skill-2
---
# Agent instructions with USE/DO NOT USE guidance
```

Agents combine multiple skills and define a specific role or responsibility.

### Commands (`commands/*.md`)

```yaml
---
name: command-name
description: What the command does
---
# Command instructions
```

Commands are custom slash commands that extend Claude Code functionality.

## Naming Conventions

- **Skills**: `{category}-{name}` (e.g., `lang-golang`, `arch-hexagonal`)
- **Agents**: Role-based names (e.g., `backend-developer`, `solution-architect`)
- **Commands**: Action-based names (e.g., `commit`, `review-pr`)

## Commit Message Format

Use semantic commit format: `type(scope): description`

**Supported types:**
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code refactoring
- `docs` - Documentation changes
- `test` - Test changes
- `chore` - Build/tooling changes

**Example:** `feat(skills): add lang-rust skill for Rust development`

## Contributing

Contributions are welcome! Whether it's new skills, improved agents, bug fixes, or documentation improvements.

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute.

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before participating.

## License

MIT - You are free to use, modify, and distribute this configuration. Attribution is required per the license terms.
