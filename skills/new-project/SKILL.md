---
name: new-project
description: Use when starting a new web project from scratch ("new project", "start a project", "bootstrap X", "/new-project"). Scaffolds the fixed web stack (Next.js + Tailwind/shadcn, Drizzle/Postgres, Better Auth, Docker), verifies it actually runs (auth round-trip, migrate, lint, build), creates the GitHub repo, and reports. One intake round, then fully autonomous.
---

# New Project

Bootstrap a new fixed-stack web project from empty folder to verified,
pushed GitHub repo. Instructions-only: write all code fresh at run time
with the **latest stable versions** of every package — never copy from
old projects, but follow the decisions and gotchas in `references/`.

## Non-negotiables

- One intake round (below), then **no further questions** for the rest of the run.
- Fixed stack only. If the user wants a different stack, this skill does not apply — say so and stop.
- Verification is evidence, not claims: a check that wasn't run is a check that failed.
- Do not proceed to commit/repo creation until every verification check passes.

## Flow

### 0. Prerequisites

Check machine prerequisites per `references/core.md` §Step 0 (pnpm, Docker
daemon, `gh auth`). Surface anything missing **before** intake so the user
knows which verification steps will be skipped.

### 1. Intake — one AskUserQuestion round

Ask in a single round:
1. **Project name** (kebab-case → folder `~/Documents/<name>/`, GitHub repo name, package name)
2. **One-line purpose** (seeds README + project CLAUDE.md)
3. **Optional modules** (multi-select): i18n · R2 storage · Anthropic AI · Brevo email — none is a valid answer
4. **Repo visibility**: private (default) or public

If the user already stated any of these in their request, don't re-ask that part.

### 2. Scaffold

Read `references/core.md` and follow it top to bottom.
Then, for each module chosen at intake, read and apply its file:
- i18n → `references/i18n.md`
- R2 storage → `references/storage-r2.md`
- Anthropic AI → `references/ai.md`
- Brevo email → `references/email.md`

Apply conventions from `references/conventions.md` throughout (docs layout,
project CLAUDE.md template, scripts, commit style, .env.example discipline).

### 3. Verify — all must pass, in this order

1. Local Postgres up (`docker compose -f docker-compose.dev.yml up -d`), then migrations and seed apply cleanly.
2. `pnpm dev` boots; the home page and `/api/health` both return HTTP 200.
3. **Auth round-trip actually performed**: sign up a scratch user and log in with it (curl against the Better Auth endpoints, or Playwright if e2e is set up). Delete or ignore the scratch user afterward.
4. `pnpm lint` passes.
5. `pnpm build` passes.

A failure is fixed, not reported around. Fix and re-run until green.

### 4. Commit + repo

1. `git init -b main`, add all, first commit: `feat: project foundation (<stack summary>, modules: <list or none>)`
2. `gh repo create <name> --private --source . --push` (visibility from intake).

### 5. Report

End with: what was built (stack + modules), verification results, every
`.env` var still needing a real value, and one suggested next step
(usually: brainstorm the first feature).

## Maintenance

When a live project teaches a lesson (better pattern, version gotcha,
broken assumption), write it into the relevant `references/` file in this
skill. The skill improves with every project.
