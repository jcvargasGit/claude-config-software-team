  #!/bin/bash
  mkdir -p ~/.claude
  ln -sf "$(pwd)/settings.json" ~/.claude/settings.json
  ln -sf "$(pwd)/CLAUDE.md" ~/.claude/CLAUDE.md
  ln -sf "$(pwd)/skills" ~/.claude/skills
  ln -sf "$(pwd)/agents" ~/.claude/agents
  ln -sf "$(pwd)/commands" ~/.claude/commands
  echo "Done! Run: claude /config to verify"