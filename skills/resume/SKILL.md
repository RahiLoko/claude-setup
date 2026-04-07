---
name: resume
description: Session start briefing. Reads the implementation plan, memory, and git log to give a clear "here's where we are and what's next" summary. Use at the start of every work session.
version: 1.0.0
activation_triggers:
  - "/resume"
  - "where were we"
  - "what's next"
  - "session start"
  - "alusta sessiooni"
---

# Resume — Session Start Briefing

When invoked, give a structured session briefing. Do this in order:

## Step 1: Read the plan

Find and read the implementation plan. Look for it at:
- `_docs/plans/*.md`
- `docs/plan*.md`
- `PLAN.md`

Extract:
- Total task count
- Which tasks are marked `[x]` (done) vs `[ ]` (not done)
- The **next incomplete task** — its number, name, and first few steps

## Step 2: Read memory

Read `MEMORY.md` from the project memory directory. Pull out:
- Any "next session" notes
- Active project decisions
- Known blockers

## Step 3: Check git

Run `git log --oneline -5` to show the last 5 commits.

## Step 4: Output the briefing

Format it exactly like this — keep it short and scannable:

---

**Session Briefing**

**Last commits:**
- `abc1234` fix: resolve mobile nav issue
- `def5678` feat: add portfolio page

**Plan progress:** X of Y tasks done

**Next task: [Task N — Name]**
> [One sentence summary of what this task does]

Steps to start:
1. [First concrete step]
2. [Second step]
3. ...

**From last session:**
> [Any notes from memory about what was in progress or what to watch out for]

**Ready.** Say "let's go" or ask about any task to begin.

---

## Rules

- Never summarize completed tasks in detail — just the count
- Always show the NEXT task, not the last completed one
- If the plan has no incomplete tasks → say "All tasks complete. What are we building next?"
- If no plan file found → say so clearly and ask where it is
- Keep the whole briefing under 20 lines
