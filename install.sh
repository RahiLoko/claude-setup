#!/usr/bin/env bash
# ============================================================
# Claude Code Skills Installer
# Run this on any new machine to install all skills
#
# Usage:
#   chmod +x install.sh && ./install.sh
#
# Or one-liner from anywhere:
#   curl -fsSL https://raw.githubusercontent.com/RahiLoko/claude-setup/main/install.sh | bash
# ============================================================

set -e

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SENTINEL="$SKILLS_DIR/.installed"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
err()  { echo -e "${RED}✗${NC} $1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Code Skills Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check git is available
if ! command -v git &> /dev/null; then
  err "git is required but not installed"
  exit 1
fi

mkdir -p "$SKILLS_DIR"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# ── Helper: clone a repo and extract skills ─────────────────
clone_extract() {
  local repo_url="$1"
  local repo_name="$2"
  local extract_fn="$3"

  echo ""
  echo "  Installing from $repo_name..."
  local dest="$TEMP_DIR/$repo_name"
  git clone --depth=1 --quiet "$repo_url" "$dest" 2>/dev/null || {
    warn "Failed to clone $repo_name — skipping"
    return
  }
  $extract_fn "$dest"
}

# ── Extraction patterns ──────────────────────────────────────

# Single SKILL.md at repo root → skill-name/SKILL.md
extract_root() {
  local src="$1" skill_name="$2"
  if [ -f "$src/SKILL.md" ]; then
    mkdir -p "$SKILLS_DIR/$skill_name"
    cp "$src/SKILL.md" "$SKILLS_DIR/$skill_name/SKILL.md"
    log "$skill_name"
  fi
}

# skills/*/SKILL.md → mkt-{name}/SKILL.md  (coreyhaines)
extract_coreyhaines() {
  local src="$1"
  for d in "$src"/skills/*/; do
    local name=$(basename "$d")
    if [ -f "$d/SKILL.md" ]; then
      mkdir -p "$SKILLS_DIR/mkt-$name"
      cp "$d/SKILL.md" "$SKILLS_DIR/mkt-$name/SKILL.md"
      log "mkt-$name"
    fi
  done
}

# */SKILL.md at repo root (wondelai)
extract_wondelai() {
  local src="$1"
  for d in "$src"/*/; do
    local name=$(basename "$d")
    if [ -f "$d/SKILL.md" ]; then
      mkdir -p "$SKILLS_DIR/wondelai-$name"
      cp "$d/SKILL.md" "$SKILLS_DIR/wondelai-$name/SKILL.md"
      log "wondelai-$name"
    fi
  done
}

# skills/category/skill/SKILL.md (entrepreneur)
extract_entrepreneur() {
  local src="$1"
  find "$src/skills" -name "SKILL.md" 2>/dev/null | while read f; do
    local name=$(basename "$(dirname "$f")")
    mkdir -p "$SKILLS_DIR/founder-$name"
    cp "$f" "$SKILLS_DIR/founder-$name/SKILL.md"
    log "founder-$name"
  done
}

# .cursor/skills/*/SKILL.md (impeccable)
extract_impeccable() {
  local src="$1"
  for d in "$src"/.cursor/skills/*/; do
    local name=$(basename "$d")
    if [ -f "$d/SKILL.md" ]; then
      mkdir -p "$SKILLS_DIR/impeccable-$name"
      cp "$d/SKILL.md" "$SKILLS_DIR/impeccable-$name/SKILL.md"
      log "impeccable-$name"
    fi
  done
}

# skills/*/SKILL.md + nested path fix (openclaudia) — no-API skills only
extract_openclaudia() {
  local src="$1"
  local no_api_skills="seo-audit seo-content-brief keyword-research content-strategy content-calendar write-blog launch-strategy lead-magnet i18n copywriting page-cro signup-flow-cro cold-email"
  for skill in $no_api_skills; do
    local f="$src/skills/$skill/SKILL.md"
    if [ -f "$f" ]; then
      mkdir -p "$SKILLS_DIR/oc-$skill"
      cp "$f" "$SKILLS_DIR/oc-$skill/SKILL.md"
      log "oc-$skill"
    fi
  done
}

# skills/emil-design-eng/SKILL.md (emilkowalski)
extract_emilkowalski() {
  local src="$1"
  local f="$src/skills/emil-design-eng/SKILL.md"
  if [ -f "$f" ]; then
    mkdir -p "$SKILLS_DIR/emilkowalski-skill"
    cp "$f" "$SKILLS_DIR/emilkowalski-skill/SKILL.md"
    log "emilkowalski-skill"
  fi
}

# .claude/skills/owasp-security/SKILL.md
extract_owasp() {
  local src="$1"
  local f="$src/.claude/skills/owasp-security/SKILL.md"
  if [ -f "$f" ]; then
    mkdir -p "$SKILLS_DIR/owasp-security"
    cp "$f" "$SKILLS_DIR/owasp-security/SKILL.md"
    log "owasp-security"
  fi
}

# email-html-mjml/SKILL.md
extract_email_mjml() {
  local src="$1"
  local f="$src/email-html-mjml/SKILL.md"
  if [ -f "$f" ]; then
    mkdir -p "$SKILLS_DIR/email-html-mjml"
    cp "$f" "$SKILLS_DIR/email-html-mjml/SKILL.md"
    log "email-html-mjml"
  fi
}

# ── Install all skills ───────────────────────────────────────

echo "[ Design & UI ]"
clone_extract "https://github.com/emilkowalski/skill"                 "emilkowalski"   extract_emilkowalski
clone_extract "https://github.com/pbakaus/impeccable"                 "impeccable"     extract_impeccable
clone_extract "https://github.com/Ashutos1997/claude-design-auditor-skill" "design-auditor" 'f() { extract_root "$1" "design-auditor"; }; f'

echo ""
echo "[ Security ]"
clone_extract "https://github.com/agamm/claude-code-owasp"           "owasp"          extract_owasp

echo ""
echo "[ Marketing & Sales ]"
clone_extract "https://github.com/coreyhaines31/marketingskills"      "coreyhaines"    extract_coreyhaines
clone_extract "https://github.com/wondelai/skills"                    "wondelai"       extract_wondelai
clone_extract "https://github.com/mfwarren/entrepreneur-claude-skills" "entrepreneur"  extract_entrepreneur
clone_extract "https://github.com/OpenClaudia/openclaudia-skills"     "openclaudia"    extract_openclaudia

echo ""
echo "[ Email ]"
clone_extract "https://github.com/framix-team/skill-email-html-mjml"  "email-mjml"     extract_email_mjml

echo ""
echo "[ Custom skills (from this repo) ]"
for d in "$SCRIPT_DIR"/skills/*/; do
  local_name=$(basename "$d")
  if [ -f "$d/SKILL.md" ]; then
    mkdir -p "$SKILLS_DIR/$local_name"
    cp "$d/SKILL.md" "$SKILLS_DIR/$local_name/SKILL.md"
    log "$local_name (custom)"
  fi
done

# ── Register startup hook in ~/.claude/settings.json ────────
SETTINGS_FILE="$HOME/.claude/settings.json"
HOOK_CMD="bash ~/Documents/claude-setup/check-skills.sh"

if [ -f "$SETTINGS_FILE" ]; then
  if ! grep -q "check-skills.sh" "$SETTINGS_FILE"; then
    # Insert hooks block after opening brace using python (available on macOS/Linux)
    python3 - <<PYEOF
import json, sys

with open("$SETTINGS_FILE", "r") as f:
    data = json.load(f)

data.setdefault("hooks", {}).setdefault("SessionStart", [])
hook_entry = {"matcher": "", "hooks": [{"type": "command", "command": "$HOOK_CMD"}]}

# avoid duplicates
existing = [h for block in data["hooks"]["SessionStart"] for h in block.get("hooks", []) if h.get("command") == "$HOOK_CMD"]
if not existing:
    data["hooks"]["SessionStart"].append(hook_entry)

with open("$SETTINGS_FILE", "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print("Startup hook registered in settings.json")
PYEOF
  else
    log "Startup hook already registered"
  fi
else
  warn "~/.claude/settings.json not found — create it first by opening Claude Code, then re-run this script"
fi

# ── Write sentinel ───────────────────────────────────────────
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$SENTINEL"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Skills installed to $SKILLS_DIR"
echo ""
echo "  Next: restart Claude Code to load all skills."
echo ""
echo "  Also re-enable official plugins (run in Claude Code):"
echo "    /plugin install superpowers@claude-plugins-official"
echo "    /plugin install vercel@claude-plugins-official"
echo "    /plugin install frontend-design@claude-plugins-official"
echo "    /plugin install feature-dev@claude-plugins-official"
echo "    /plugin install commit-commands@claude-plugins-official"
echo "    /plugin install claude-md-management@claude-plugins-official"
echo "    /plugin install code-review@claude-plugins-official"
echo "    /plugin install hookify@claude-plugins-official"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
