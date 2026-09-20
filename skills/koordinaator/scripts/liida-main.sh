#!/bin/bash
# usage: liida-main.sh <branch> [repo-dir] [worktree-dir] [base-branch]
# Merges origin/main into <branch> in its own worktree, resolves conflicts in
# the coordination docs (SEIS/LAHTISED/POSTKAST) by keeping BOTH sides (main's block first, then the
# branch's), refuses to auto-resolve anything else, and pushes.
# Code/test conflicts stop here on purpose: read both sides, keep both
# behaviours, run tsc + tests, commit by file name (never `git add -A`).
set -e
B=$1; REPO=${2:-$(pwd)}; W=${3:-/tmp/wt-liida}; BASE=${4:-$(git -C "${2:-$(pwd)}" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed "s|origin/||")}; BASE=${BASE:-main}
cd "$REPO"; git fetch -q origin "$BASE" "$B"
rm -rf "$W"; git worktree prune; git worktree add -q "$W" "origin/$B"; cd "$W"; git checkout -q -B "$B"
if git merge -q --no-edit "origin/$BASE" >/dev/null 2>&1; then echo "clean merge"; else
  u=$(git diff --name-only --diff-filter=U | tr '\n' ' '); echo "conflicts: $u"
  python3 - "$u" <<'PY'
import re, sys
DOCS = ("docs/koordinatsioon/POSTKAST.md", "docs/koordinatsioon/LAHTISED.md", "docs/koordinatsioon/SEIS.md")
for p in sys.argv[1].split():
    if p not in DOCS and not p.startswith("docs/"): sys.exit("non-doc conflict, resolve by hand: " + p)
    s = open(p, encoding="utf-8").read()
    s2 = re.sub(r"<<<<<<< [^\n]*\n(.*?)=======\n(.*?)>>>>>>> [^\n]*\n", lambda m: m.group(2) + m.group(1), s, flags=re.S)
    assert "<<<<<<<" not in s2; open(p, "w", encoding="utf-8").write(s2)
print("docs resolved (both sides kept)")
PY
  git add docs; git commit -q --no-edit; fi
git push -q origin "$B"; git log --oneline -1; echo "HEAD $(git rev-parse HEAD)"
