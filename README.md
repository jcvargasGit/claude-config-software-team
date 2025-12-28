# Claude Code Configuration

Personal Claude Code configuration files for skills, agents, and settings.

## Structure

```
├── settings.json    # Claude Code settings
├── skills/          # Custom skill definitions
├── agents/          # Custom agent definitions
├── commands/        # Custom slash commands
└── setup.sh         # Installation script
```

## Setup

Run the setup script to symlink configuration files to `~/.claude`:

```bash
./setup.sh
```

This creates symbolic links from this repository to your Claude configuration directory, allowing you to version control your settings.

## Verify

After running setup, verify the configuration:

```bash
claude /config
```
