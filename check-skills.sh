#!/usr/bin/env bash
# Startup hook — checks if skills are installed, reminds to /resume
# Registered in ~/.claude/settings.json as a SessionStart hook

SENTINEL="$HOME/.claude/skills/.installed"

if [ ! -f "$SENTINEL" ]; then
  echo ""
  echo "⚠️  Claude skills not installed on this machine."
  echo "   Run: cd ~/Documents/claude-setup && ./install.sh"
  echo ""
else
  echo ""
  echo "💡 Type /resume to get a session briefing — plan status, next task, last commits."
  echo ""
fi
