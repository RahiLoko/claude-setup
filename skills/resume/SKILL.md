---
name: resume
description: Session start briefing. Reads RESUME.md, the implementation plan, memory, and git state to give a clear "here's where we are and what's next" summary. Use at the start of every work session.
version: 2.0.0
activation_triggers:
  - "/resume"
  - "where were we"
  - "what's next"
  - "session start"
  - "alusta sessiooni"
---

# Resume — Session Start Briefing

When invoked, build a structured briefing for the current project. Work
generically — never assume a specific project; pull every fact from the
repo you are standing in.

## Step 1: Read RESUME.md (if present)

`docs/RESUME.md` is the authoritative session-context file when it exists.
Extract: current phase, done vs pending, locked decisions, "what to do
next". If absent, skip — don't ask about it.

## Step 2: Read the active plan

Plans live at `docs/superpowers/plans/*.md` (current convention). Legacy
fallbacks, in order: `_docs/plans/*.md`, `docs/plan*.md`, `PLAN.md`.
Use the most recently modified plan with incomplete `- [ ]` checkboxes.

Extract: total task count, done vs open, and the **next incomplete task**
(number, name, first steps).

## Step 3: Use memory

The project memory index (MEMORY.md) is auto-loaded into context. Use it
directly; open a linked memory file only if it clearly concerns this
project. Pull out "next session" notes, active decisions, known blockers.

## Step 4: Check git state

- `git log --oneline -5`
- `git status --porcelain` — flag uncommitted changes; they're usually
  interrupted work
- Current branch — flag if it's not the default branch (unfinished feature)
- If a remote exists: `gh pr list --state open` — open PRs are usually
  waiting on the merge gate

## Step 5: Output the briefing

Keep it short and scannable, ≤ 25 lines:

---

**Session Briefing — <project folder name>**

**Branch:** `<branch>`<, N uncommitted changes / open PR #X if any>

**Last commits:**
- `abc1234` <subject>
- `def5678` <subject>

**Plan progress:** X of Y tasks done

**Next task: [Task N — Name]**
> One sentence on what it does.

Steps to start:
1. <first concrete step>
2. <second step>

**From last session / memory:**
> <in-progress notes, blockers, decisions to respect>

**Ready.** Say "let's go" or ask about any task to begin.

---

## Rules

- Never summarize completed tasks in detail — just the count.
- Always show the NEXT task, not the last completed one.
- Uncommitted changes or an open PR lead the briefing — they represent
  interrupted work and the human merge gate.
- Locked decisions come from RESUME.md / CLAUDE.md / memory — never from
  this skill file.
- If the plan is fully complete → say "All tasks complete." and suggest
  `superpowers:brainstorming` for what's next.
- If nothing is found (no RESUME.md, no plan) → say so and give the
  git-state briefing only.
