# Claude Code Configuration

Personal Claude Code configuration files for skills, agents, and settings.

## Structure

```
├── settings.json
├── CLAUDE.md
├── skills/
│   ├── lang-golang/
│   ├── lang-typescript/
│   ├── lang-javascript/
│   ├── frontend-html/
│   ├── frontend-css/
│   ├── frontend-react/
│   ├── cloud-aws/
│   ├── devops-terraform/
│   ├── devops-github-actions/
│   ├── spec-user-stories/
│   ├── spec-acceptance-criteria/
│   ├── spec-prd/
│   └── spec-api-specs/
├── agents/
│   ├── senior-cloud-architect.md
│   ├── senior-backend-developer.md
│   ├── senior-frontend-engineer.md
│   └── product-manager.md
├── commands/
└── setup.sh
```

## Skills

Skills are organized by category prefix:

| Prefix | Category | Skills |
|--------|----------|--------|
| `lang-` | Languages | golang, typescript, javascript |
| `frontend-` | Frontend | html, css, react |
| `cloud-` | Cloud Providers | aws |
| `devops-` | DevOps | terraform, github-actions |
| `spec-` | Specifications | user-stories, acceptance-criteria, prd, api-specs |

## Agents

| Agent | Purpose | Skills |
|-------|---------|--------|
| `senior-cloud-architect` | Cloud architecture, IaC, system design | spec-acceptance-criteria, spec-api-specs, cloud-aws |
| `senior-backend-developer` | Go services, Terraform, CI/CD | lang-golang, devops-terraform, devops-github-actions (+ inherits cloud-architect) |
| `senior-frontend-engineer` | Frontend development, React, TypeScript | lang-typescript, lang-javascript, frontend-html, frontend-css, frontend-react, spec-acceptance-criteria |
| `product-manager` | Spec-driven development, PRDs, user stories | spec-user-stories, spec-acceptance-criteria, spec-prd, spec-api-specs |

## Setup

Run the setup script to symlink configuration files to `~/.claude`:

```bash
./setup.sh
```

## Verify

After running setup, verify the configuration:

```bash
claude /config
```

## License

MIT
