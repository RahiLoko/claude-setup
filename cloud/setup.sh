#!/usr/bin/env bash
# Cloud setup — gives a Claude Code cloud session the kit the office machine has.
#
# A cloud session starts from a fresh clone of one repo. Nothing in the office
# machine's ~/.claude reaches it: no global rules, no personal skills. This
# script puts the small part that is actually used into the cloud machine:
#
#   rules   ~/.claude/CLAUDE.md   cloud/CLAUDE.md (Autonomy) + MODELS.md
#   skills  resume, new-project   from this repo
#           impeccable, emil-design-eng, owasp-security   from their own repos,
#           each pinned to a commit so a change upstream cannot silently
#           change what an unattended cloud session is told to do
#
# In the cloud environment's "Setup script" box, paste this ONE line:
#
#   git clone --depth 1 https://github.com/RahiLoko/claude-setup /tmp/claude-setup && bash /tmp/claude-setup/cloud/setup.sh
#
# Not `set -e` on purpose: a setup script that exits non-zero can keep the
# environment from starting. Every step reports what it did and carries on,
# and the script always exits 0.
#
# Skills that come from the claude.ai account (koordinaator, pm-coworker,
# standardid, the blog writer …) and account plugins (Superpowers, Security
# Guidance) load in cloud sessions by themselves and are not installed here.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
INSTALLED=""
PROBLEMS=""

say()  { echo "[cloud-setup] $1"; }
fail() { echo "[cloud-setup] PROBLEM: $1"; PROBLEMS="$PROBLEMS\n  - $1"; }

mkdir -p "$SKILLS_DIR" || fail "could not create $SKILLS_DIR"

# ── Copy one skill folder ────────────────────────────────────
copy_skill() {
  local src="$1" name="$2"
  if [ ! -f "$src/SKILL.md" ]; then
    fail "skill $name: no SKILL.md at $src"
    return 1
  fi
  rm -rf "${SKILLS_DIR:?}/$name"
  mkdir -p "$SKILLS_DIR/$name" && cp -R "$src/." "$SKILLS_DIR/$name/" || {
    fail "skill $name: copy failed"
    return 1
  }
  rm -rf "$SKILLS_DIR/$name/.git"
  INSTALLED="$INSTALLED $name"
  say "skill installed: $name"
}

# ── Fetch one pinned commit of a repo and copy a skill out of it ──
# Usage: pinned_skill <repo url> <commit> <path inside repo> <skill name>
pinned_skill() {
  local url="$1" sha="$2" sub="$3" name="$4"
  local tmp
  tmp="$(mktemp -d)" || { fail "skill $name: no temp folder"; return 1; }
  if git -C "$tmp" init --quiet \
     && git -C "$tmp" remote add origin "$url" \
     && git -C "$tmp" fetch --quiet --depth 1 origin "$sha" \
     && git -C "$tmp" checkout --quiet FETCH_HEAD; then
    copy_skill "$tmp/$sub" "$name"
  else
    fail "skill $name: could not fetch $url at $sha (network access or a moved commit)"
  fi
  rm -rf "$tmp"
}

# ── 1. Global rules ──────────────────────────────────────────
# Written only when the cloud machine has none, so a rules file a session or
# another script already made is never replaced.
RULES="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$RULES" ]; then
  say "rules: $RULES already exists, left alone"
elif [ ! -f "$REPO_DIR/cloud/CLAUDE.md" ]; then
  fail "rules: cloud/CLAUDE.md missing from the repo"
else
  {
    cat "$REPO_DIR/cloud/CLAUDE.md"
    if [ -f "$REPO_DIR/MODELS.md" ]; then
      echo
      echo "<!-- BEGIN claude-setup:models -->"
      cat "$REPO_DIR/MODELS.md"
      echo "<!-- END claude-setup:models -->"
    fi
  } > "$RULES" && say "rules: wrote $RULES" || fail "rules: could not write $RULES"
fi

# ── 2. Own skills, from this repo ────────────────────────────
for name in resume new-project; do
  copy_skill "$REPO_DIR/skills/$name" "$name"
done

# ── 3. Third-party skills in the kit, pinned ─────────────────
# To move a pin: `git ls-remote <url> HEAD`, read the change upstream, then
# put the new commit here. The *_URL / *_SHA variables exist so the script
# can be tested against local repos.
if command -v git > /dev/null 2>&1; then
  pinned_skill "${IMPECCABLE_URL:-https://github.com/pbakaus/impeccable}" \
               "${IMPECCABLE_SHA:-b4bff1626c344067788c2679f048a20057c7cc5a}" \
               ".cursor/skills/impeccable" "impeccable"
  pinned_skill "${EMIL_URL:-https://github.com/emilkowalski/skill}" \
               "${EMIL_SHA:-4061b67b8d976a186aca118594f54b638c5f718a}" \
               "skills/emil-design-eng" "emil-design-eng"
  pinned_skill "${OWASP_URL:-https://github.com/agamm/claude-code-owasp}" \
               "${OWASP_SHA:-1ae29cb22518560e3625d77f2ae64f61647d9201}" \
               ".claude/skills/owasp-security" "owasp-security"
else
  fail "git not found: impeccable, emil-design-eng and owasp-security not installed"
fi

# ── Report ───────────────────────────────────────────────────
say "done. skills in $SKILLS_DIR:${INSTALLED:- none}"
if [ -n "$PROBLEMS" ]; then
  printf "[cloud-setup] finished with problems:$PROBLEMS\n"
fi
exit 0
