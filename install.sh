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

# ── Install one skill directory ──────────────────────────────
# Copies SKILL.md *and* the supporting dirs a skill ships. Skills
# routinely reference reference/*.md and scripts/*; copying only
# SKILL.md installs a skill whose own instructions point at files
# that do not exist. Never copies .git.
install_skill_dir() {
  local src="$1" name="$2"
  [ -f "$src/SKILL.md" ] || return 0

  local dest="$SKILLS_DIR/$name"
  rm -rf "${dest:?}"
  mkdir -p "$dest"
  cp "$src/SKILL.md" "$dest/SKILL.md"

  local sub
  for sub in reference references scripts docs assets templates; do
    if [ -d "$src/$sub" ]; then
      cp -R "$src/$sub" "$dest/$sub"
    fi
  done

  echo "$name" >> "$MANIFEST_NEW"
  log "$name"
}

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
trap 'rm -rf "$TEMP_DIR"' EXIT

# Names of every skill installed by this run. Compared against the
# previous run's manifest so renamed/removed upstream skills get pruned
# instead of lingering forever as stale duplicates.
MANIFEST="$SKILLS_DIR/.manifest"
MANIFEST_NEW="$TEMP_DIR/manifest.new"
: > "$MANIFEST_NEW"

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

# Single skill at repo root (design-auditor)
extract_design_auditor() {
  install_skill_dir "$1" "design-auditor"
}

# skills/*/SKILL.md → mkt-{name}  (coreyhaines)
extract_coreyhaines() {
  local d
  for d in "$1"/skills/*/; do
    install_skill_dir "$d" "mkt-$(basename "$d")"
  done
}

# */SKILL.md at repo root (wondelai)
extract_wondelai() {
  local d
  for d in "$1"/*/; do
    install_skill_dir "$d" "wondelai-$(basename "$d")"
  done
}

# skills/category/skill/SKILL.md (entrepreneur)
extract_entrepreneur() {
  local f
  while IFS= read -r f; do
    local d; d="$(dirname "$f")"
    install_skill_dir "$d" "founder-$(basename "$d")"
  done < <(find "$1/skills" -name SKILL.md 2>/dev/null)
}

# .cursor/skills/impeccable/ (impeccable)
# Upstream consolidated the former ~18 sub-skills (polish, animate,
# audit, …) into a single umbrella skill. Installing it as one dir
# keeps SKILL.md next to its reference/ and scripts/.
extract_impeccable() {
  install_skill_dir "$1/.cursor/skills/impeccable" "impeccable"
}

# skills/*/SKILL.md (openclaudia) — no-API skills only
extract_openclaudia() {
  local no_api_skills="seo-audit seo-content-brief keyword-research content-strategy content-calendar write-blog launch-strategy lead-magnet i18n copywriting page-cro signup-flow-cro cold-email"
  local skill
  for skill in $no_api_skills; do
    install_skill_dir "$1/skills/$skill" "oc-$skill"
  done
}

# skills/emil-design-eng/SKILL.md (emilkowalski)
extract_emilkowalski() {
  install_skill_dir "$1/skills/emil-design-eng" "emilkowalski-skill"
}

# .claude/skills/owasp-security/SKILL.md
extract_owasp() {
  install_skill_dir "$1/.claude/skills/owasp-security" "owasp-security"
}

# email-html-mjml/SKILL.md
extract_email_mjml() {
  install_skill_dir "$1/email-html-mjml" "email-html-mjml"
}

# ── Install all skills ───────────────────────────────────────

echo "[ Design & UI ]"
clone_extract "https://github.com/emilkowalski/skill"                 "emilkowalski"   extract_emilkowalski
clone_extract "https://github.com/pbakaus/impeccable"                 "impeccable"     extract_impeccable
clone_extract "https://github.com/Ashutos1997/claude-design-auditor-skill" "design-auditor" extract_design_auditor

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
  install_skill_dir "$d" "$(basename "$d")"
done

# ── Register startup hook in ~/.claude/settings.json ────────
SETTINGS_FILE="$HOME/.claude/settings.json"
HOOK_CMD="bash ~/Documents/claude-setup/check-skills.sh"

if ! command -v python3 &> /dev/null; then
  warn "python3 not found — cannot register the startup hook automatically"
elif [ -f "$SETTINGS_FILE" ]; then
  # Paths go in as argv, not interpolated into the source: $HOME may
  # contain spaces (and on Windows, backslashes).
  cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
  python3 - "$SETTINGS_FILE" "$HOOK_CMD" <<'PYEOF'
import json, sys

settings_file, hook_cmd = sys.argv[1:3]

with open(settings_file, encoding="utf-8") as f:
    data = json.load(f)

session_start = data.setdefault("hooks", {}).setdefault("SessionStart", [])

already = any(
    h.get("command") == hook_cmd
    for block in session_start
    for h in block.get("hooks", [])
)

if already:
    print("  startup hook already registered")
else:
    session_start.append(
        {"matcher": "", "hooks": [{"type": "command", "command": hook_cmd}]}
    )
    with open(settings_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print("  startup hook registered in settings.json")
PYEOF
  log "Startup hook checked (backup: settings.json.bak)"
else
  warn "~/.claude/settings.json not found — create it first by opening Claude Code, then re-run this script"
fi

# ── Sync model rules into global CLAUDE.md ──────────────────
# MODELS.md is synced into a managed block. Hand-written global
# instructions outside the block are preserved. Never overwrite the
# whole file — it is the user's global config, not ours.
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
BEGIN_MARK="<!-- BEGIN claude-setup:models -->"
END_MARK="<!-- END claude-setup:models -->"

if [ ! -f "$SCRIPT_DIR/MODELS.md" ]; then
  warn "MODELS.md not found — skipping global CLAUDE.md sync"
elif [ ! -f "$CLAUDE_MD" ]; then
  { echo "$BEGIN_MARK"; cat "$SCRIPT_DIR/MODELS.md"; echo "$END_MARK"; } > "$CLAUDE_MD"
  log "Created ~/.claude/CLAUDE.md with model selection rules"
else
  cp "$CLAUDE_MD" "$CLAUDE_MD.bak"
  python3 - "$CLAUDE_MD" "$SCRIPT_DIR/MODELS.md" "$BEGIN_MARK" "$END_MARK" <<'PYEOF'
import re, sys

claude_md, models_md, begin, end = sys.argv[1:5]

with open(models_md, encoding="utf-8") as f:
    block = begin + "\n" + f.read().strip() + "\n" + end

with open(claude_md, encoding="utf-8") as f:
    current = f.read()

# Greedy: the block runs from the FIRST begin marker to the LAST end
# marker. Non-greedy would stop at any marker quoted inside the block
# (e.g. documentation showing the marker syntax) and orphan the tail.
pattern = re.compile(re.escape(begin) + ".*" + re.escape(end), re.S)
if pattern.search(current):
    # Use a lambda so backslashes / \g in the block are not read as escapes.
    updated = pattern.sub(lambda _: block, current)
else:
    updated = current.rstrip() + "\n\n" + block + "\n"

if updated != current:
    with open(claude_md, "w", encoding="utf-8") as f:
        f.write(updated)
    print("  model rules block updated")
else:
    print("  model rules block already current")
PYEOF
  log "Model rules synced into ~/.claude/CLAUDE.md (backup: CLAUDE.md.bak)"
fi

# ── Prune skills upstream no longer provides ─────────────────
# Only removes names that a PREVIOUS run of this script recorded in
# .manifest and that this run did not reinstall — i.e. renamed or
# dropped upstream. Skills installed by any other means are never
# in the manifest, so they are never touched.
sort -u -o "$MANIFEST_NEW" "$MANIFEST_NEW"

if [ -f "$MANIFEST" ]; then
  while IFS= read -r old_name; do
    [ -n "$old_name" ] || continue
    if ! grep -qxF "$old_name" "$MANIFEST_NEW"; then
      rm -rf "${SKILLS_DIR:?}/$old_name"
      warn "pruned $old_name (renamed or dropped upstream)"
    fi
  done < "$MANIFEST"
fi

cp "$MANIFEST_NEW" "$MANIFEST"
log "$(wc -l < "$MANIFEST" | tr -d ' ') skills tracked in .manifest"

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
