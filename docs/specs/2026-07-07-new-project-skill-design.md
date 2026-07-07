# `/new-project` Skill — Design

**Date:** 2026-07-07
**Status:** Approved by Rahi (brainstorming session)
**Location of skill:** `~/.claude/skills/new-project/`

## Problem

Every new web project (brickbox-new, taevakera, ybn-app, 3dlab-ee, …) re-assembles
the same foundation by hand: Next.js + Tailwind/shadcn, Drizzle + Postgres, Better
Auth, Docker, dev/deploy scripts, `docs/` layout, project `CLAUDE.md`. brickbox-new
was literally a clean-slate rebuild whose stated goal was "keep the working
foundation, replace the domain." Conventions also drift between projects
(`_docs` vs `docs`, `dev.sh` vs `dev.ps1`, differing compose setups).

## Decision summary

| Question | Decision |
|---|---|
| Pain addressed | The whole path: empty folder → first real feature commit |
| Form | **Pure Claude skill** — no template repo, no scaffold CLI |
| Stack scope | **Fixed web stack only**: Next.js + Tailwind v4 + shadcn, Drizzle + Postgres, Better Auth, Docker. Other project types stay manual. |
| Source of foundation code | **Instructions only** — the skill carries decisions, patterns, and gotchas; Claude writes current code fresh each run with latest package versions. No frozen code snippets to rot. |
| Finish line | **Verified local + repo** — dev server runs, migrations/seed apply, auth round-trip works, lint + build pass, GitHub repo created and pushed. Deploy is out of scope. |
| Optional pieces | i18n, R2, AI, email are **per-run intake choices**, not defaults |
| Structure | **Modular skill** — lean SKILL.md flow + per-module reference files loaded on demand |

## Skill structure

```
~/.claude/skills/new-project/
├── SKILL.md              # flow: intake → scaffold → verify → commit → report
├── docs/specs/           # this design doc
└── references/
    ├── core.md           # fixed-stack scaffold instructions + gotchas
    ├── i18n.md           # optional: next-intl (ET/EN default)
    ├── storage-r2.md     # optional: Cloudflare R2 upload wiring
    ├── ai.md             # optional: Anthropic SDK + MODELS.md defaults
    ├── email.md          # optional: Brevo transactional email
    └── conventions.md    # cross-project conventions + CLAUDE.md template
```

No code files anywhere in the skill. Reference files specify *what to build and
which decisions are locked* (package choices, file layout, patterns, known
pitfalls), never frozen source code.

## Flow (SKILL.md)

### 1. Intake — one structured question round, then no more questions

- Project name (kebab-case; becomes folder under `~/Documents/`, repo name, package name)
- One-line purpose (seeds README + project CLAUDE.md)
- Optional modules (multi-select): i18n / R2 storage / Anthropic AI / Brevo email
- Repo visibility (private default)

Everything else is decided by convention. After intake the run is autonomous.

### 2. Scaffold — per `references/core.md` + chosen module files

- Create project folder in `~/Documents/<name>/`
- Latest `create-next-app` (App Router, TypeScript, Tailwind), shadcn init
- Drizzle ORM + Postgres: `db/schema.ts`, drizzle config, local Postgres via
  `docker-compose.dev.yml`, migrate + seed scripts
- Better Auth wiring (email/password baseline)
- `.env.example` with every var the project needs, placeholders documented
- Production `Dockerfile` (standalone output) + `docker-compose.yml`
- `dev.sh` + `dev.ps1`
- `docs/` skeleton incl. `docs/superpowers/specs/`
- Project `CLAUDE.md` from the conventions template
- Minimal GitHub Actions CI: lint + build
- Each chosen optional module added per its reference file

### 3. Verify — evidence, not claims

- `pnpm dev` boots and serves the home page
- Migrations + seed apply against local Postgres
- Auth round-trip actually performed: signup then login succeeds
- `pnpm lint` and `pnpm build` pass

A failure is fixed, not reported around. The run does not proceed to commit
until all checks pass.

### 4. Commit + repo

- `git init`, conventional first commit (`feat: project foundation …`)
- `gh repo create` (visibility from intake), push

### 5. Report

- What was built, module list
- Env vars still needing real values
- Suggested first next step (e.g. "brainstorm the first feature")

## Reference file contents

**core.md** — the fixed-stack recipe: locked package choices, file layout,
and the accumulated gotchas from existing projects (Docker entrypoint
migration pattern, Next standalone output for Docker, seed-admin pattern,
etc.). Written as decisions and patterns so it survives version bumps.

**i18n.md** — next-intl with locale routing, ET/EN message files, hreflang
basics. Included at scaffold time because retrofitting i18n is painful.

**storage-r2.md** — R2 client + upload pattern with env placeholders; bucket
creation itself stays a per-project manual step.

**ai.md** — Anthropic SDK helper/route; bakes in the MODELS.md
model-selection defaults (Sonnet default, Haiku for cheap calls, Opus for
high-stakes).

**email.md** — Brevo transactional helper (verification, notifications) with
env placeholders.

**conventions.md** — the canonical cross-project conventions, ending drift
for new projects:

- `docs/` (not `_docs`), specs under `docs/superpowers/specs/`
- Project `CLAUDE.md` template: stack summary, commands, pointer to
  source-of-truth docs (mirrors the brickbox-new "docs win" pattern)
- Script naming: `dev.sh` + `dev.ps1` pair
- Conventional-commit style
- `.env.example` discipline: every required var listed, never a real secret

## Maintenance model

When a live project teaches something (better auth pattern, Docker fix, new
package major), the lesson is written into the relevant reference file. The
skill improves with each project instead of rotting — this replaces the
continuous testing a template repo would have provided.

## Out of scope (deliberate)

- Deploying to Coolify/Hetzner — a later step once a project earns it
- Non-web project types (Python tools, Solibri plugins, static sites)
- Migrating existing projects to the conventions
- Billing/payments, CMS, and anything else not listed in the stack

## Success criteria

A run of `/new-project` ends with a GitHub repo whose clone boots, migrates,
seeds, authenticates a user, lints, and builds — with docs and CLAUDE.md in
place — without the user answering more than the single intake round.
