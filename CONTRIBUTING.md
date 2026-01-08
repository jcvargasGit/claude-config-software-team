# Contributing to Claude Code Configuration

Thank you for your interest in contributing! This repository contains Claude Code configuration files (skills, agents, and commands) that help improve project creation workflows.

## How to Contribute

### Adding a New Skill

1. Create a directory under `skills/` following the naming convention:
   - `lang-{language}` for programming languages
   - `frontend-{technology}` for frontend technologies
   - `cloud-{provider/service}` for cloud-related skills
   - `devops-{tool}` for DevOps tools
   - `spec-{type}` for specification templates
   - `arch-{pattern}` for architecture patterns

2. Create a `SKILL.md` file inside the directory with the skill definition

3. Follow existing skills as templates for structure and format

### Adding a New Agent

1. Create a markdown file under `agents/` with the agent name (e.g., `my-agent.md`)

2. Include:
   - Clear purpose and responsibilities
   - When to use the agent
   - Skills the agent should reference

3. Agents should be categorized by their primary function (architect, developer, engineer, etc.)

### Adding a New Command

1. Create a markdown file under `commands/` with the command name (e.g., `my-command.md`)

2. Document the command's purpose and expected behavior

### Improving Existing Content

- Fix typos, improve clarity, or enhance documentation
- Add missing edge cases to skills
- Improve prompt engineering in agents or commands

## Contribution Guidelines

### Code Style

- Use clear, concise language in skill definitions
- Follow the existing structure and formatting patterns
- Keep skill files focused and specific to their domain

### Commit Messages

Use semantic commit messages:
- `feat:` for new skills, agents, or commands
- `fix:` for corrections and bug fixes
- `docs:` for documentation improvements
- `refactor:` for restructuring without changing functionality

Example: `feat(skills): add lang-rust skill for Rust development`

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/my-new-skill`)
3. Make your changes
4. Test your changes with Claude Code
5. Commit with semantic messages
6. Push to your fork
7. Open a Pull Request with:
   - Clear description of changes
   - Reasoning for the addition/change
   - Any relevant examples or use cases

## Testing Your Changes

Before submitting, verify your changes work:

```bash
# Run setup to symlink configs
./setup.sh

# Verify Claude Code picks up your changes
claude /config
```

## Questions or Ideas?

Feel free to open an issue to:
- Discuss new skill ideas before implementing
- Report problems with existing configurations
- Suggest improvements to the structure

## Attribution

This project is MIT licensed. When using or adapting these configurations, please include attribution to this repository as required by the license.

Thank you for contributing!
