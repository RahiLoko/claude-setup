# `/new-project` Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `/new-project` personal Claude skill that scaffolds, verifies, and publishes a new fixed-stack web project from a single intake round.

**Architecture:** A modular instructions-only skill at `~/.claude/skills/new-project/`: `SKILL.md` holds the run flow (intake → scaffold → verify → commit → report); `references/` holds one file per concern (core stack, four optional modules, conventions), loaded only when needed. No code files anywhere in the skill.

**Tech Stack:** Markdown skill files only. The stack the skill *describes*: Next.js (App Router) + Tailwind v4 + shadcn, Drizzle + Postgres, Better Auth, Docker, pnpm, GitHub CLI.

## Global Constraints

- Skill root: `C:\Users\Rahi Lokotar\.claude\skills\new-project\` (referred to below as `<root>`)
- **Instructions only** — reference files contain decisions, patterns, commands, and gotchas; **never frozen application source code**. Markdown *templates* (CLAUDE.md template, .env.example var list) and shell *commands* are allowed; TypeScript/JS/config source blocks are not.
- Fixed stack, exactly: Next.js (App Router, TypeScript, `src/` dir) · Tailwind v4 · shadcn · Drizzle ORM · Postgres · Better Auth · Docker · pnpm
- Optional modules, exactly four: i18n (next-intl), storage (Cloudflare R2), AI (Anthropic SDK), email (Brevo)
- Finish line of a skill run: dev server boots, migrate+seed apply, auth signup→login round-trip proven, `pnpm lint` and `pnpm build` pass, GitHub repo created and pushed
- New projects are created in `~/Documents/<kebab-name>/`, repo private by default
- Every SKILL.md/reference file must keep frontmatter or headings parseable and stay focused (target ≤ 150 lines per reference file)
- Commit after every task, conventional-commit style, in the skill repo (initialized in Task 1)

---

### Task 1: Skill scaffold, git init, and SKILL.md

**Files:**
- Create: `<root>\SKILL.md`
- Create: `<root>\.gitignore`
- (Already exist: `<root>\docs\specs\2026-07-07-new-project-skill-design.md`, this plan)

**Interfaces:**
- Produces: `SKILL.md` referencing exactly these files, which later tasks must create with these exact names: `references/core.md`, `references/conventions.md`, `references/i18n.md`, `references/storage-r2.md`, `references/ai.md`, `references/email.md`.

- [ ] **Step 1: Initialize git in the skill folder**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git init -b main
```

- [ ] **Step 2: Write `.gitignore`**

```
# nothing generated yet; placeholder to keep repo tidy
*.tmp
```

- [ ] **Step 3: Write `SKILL.md` with this exact content**

````markdown
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
2. `pnpm dev` boots and the home page returns HTTP 200.
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
````

- [ ] **Step 4: Verify structure**

Run: `head -5 "/c/Users/Rahi Lokotar/.claude/skills/new-project/SKILL.md"`
Expected: frontmatter opens with `---` and `name: new-project`.
Check: every `references/*.md` path named in SKILL.md matches the six filenames listed in this task's Interfaces block.

- [ ] **Step 5: Commit**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git add -A && git commit -m "feat: skill flow (SKILL.md) + spec/plan docs"
```

---

### Task 2: `references/core.md` — the fixed-stack recipe

**Files:**
- Create: `<root>\references\core.md`

**Interfaces:**
- Consumes: referenced by SKILL.md step "Scaffold".
- Produces: the canonical scaffold order and locked decisions; conventions file (Task 3) must not contradict it.

- [ ] **Step 1: Write `references/core.md` with this exact content**

````markdown
# Core Stack Recipe

Write everything fresh with current stable versions. These are the locked
decisions and known pitfalls — not code to copy.

## Locked decisions

- Package manager: **pnpm**.
- `create-next-app@latest`: TypeScript, App Router, Tailwind, `src/` directory, no default import alias changes.
- UI: shadcn (`pnpm dlx shadcn@latest init`), components added on demand only — don't pre-install a component zoo (YAGNI).
- DB: Drizzle ORM + Postgres. Schema in `db/schema.ts` (repo root `db/`, not `src/`), `drizzle.config.ts` at root. Scripts: `db:generate`, `db:migrate`, `db:seed`, `db:seed-admin`.
- Auth: Better Auth, email/password baseline. Server config in `src/lib/auth.ts`, client in `src/lib/auth-client.ts`, route handler under `src/app/api/auth/[...all]/`.
- Seed admin from `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD` env vars (never hardcoded).

## Scaffold order

1. `pnpm create next-app@latest <name>` in `~/Documents/` with the options above; `cd` in.
2. shadcn init.
3. `docker-compose.dev.yml`: single Postgres service for local dev.
   - **Bind to 127.0.0.1** (`127.0.0.1:<port>:5432`) — Docker published ports bypass UFW/firewalls; never expose a dev DB on 0.0.0.0.
   - Pick a host port unlikely to clash with other projects' dev DBs (5433+; check `docker ps` first).
4. Drizzle: install, config, minimal starter schema = whatever Better Auth requires plus nothing else. Generate + note the migrate command.
5. Better Auth wired to Drizzle. Use its CLI/generator for the auth schema tables if available in the current version.
6. `.env.example` (see conventions.md discipline) + `.env.local` filled with real local values (generated auth secret, local DB URL).
7. Minimal home page: project name, one-line purpose, login/signup links — proves rendering + routing. No design work; that comes with the first real feature.
8. Production `Dockerfile` + `docker-compose.yml`:
   - Next.js **standalone output** (`output: 'standalone'` in next.config) — without it the Docker image balloons or fails.
   - Multi-stage build; final stage runs the standalone server as non-root.
   - Run DB migrations from the container **entrypoint script** (docker-entrypoint.sh) so deploys migrate themselves.
9. Dev scripts: `dev.sh` and `dev.ps1` pair — both: start dev DB container, run migrations, start `pnpm dev`.
10. `docs/` skeleton + project `CLAUDE.md` per conventions.md.
11. CI: `.github/workflows/ci.yml` — on push/PR: pnpm install (with cache), `pnpm lint`, `pnpm build`. Nothing else (no deploy, no test matrix) until the project earns it.

## Known gotchas (from brickbox / taevakera / ybn / 3dlab)

- Tailwind v4 config lives in CSS (`@import "tailwindcss"` + `@theme`), not `tailwind.config.ts` — don't generate a v3-style config.
- Better Auth needs `BETTER_AUTH_SECRET` and a correct `BETTER_AUTH_URL`/base URL per environment; missing URL is the classic "works locally, breaks in Docker" bug.
- Drizzle migrations in CI/Docker need `DATABASE_URL` at build vs runtime kept straight: migrations run at **runtime** (entrypoint), never during `next build`.
- `next build` must not require a live DB. Any page that queries the DB must be dynamic (`export const dynamic = 'force-dynamic'`) or query at request time only.
- pnpm on Windows + Docker: ensure `.dockerignore` excludes `node_modules`, `.next`, `.git` — or builds are slow and images dirty.

## Verification commands (used by SKILL.md step 3)

- DB up: `docker compose -f docker-compose.dev.yml up -d --wait`
- Migrate + seed: `pnpm db:migrate && pnpm db:seed && pnpm db:seed-admin`
- Dev boot: start `pnpm dev` in background, then `curl -s -o /dev/null -w "%{http_code}" http://localhost:3000` → expect `200`
- Auth round-trip (adjust paths to the current Better Auth version's REST endpoints):
  sign-up POST then sign-in POST with a scratch email; expect 2xx and a session token/cookie on sign-in.
- `pnpm lint` → exit 0. `pnpm build` → exit 0.
````

- [ ] **Step 2: Verify structure**

Check: file is ≤ 150 lines; contains **no** TypeScript/JS/JSON source blocks (commands and file *names* only); every script name mentioned (`db:generate`, `db:migrate`, `db:seed`, `db:seed-admin`, `dev.sh`, `dev.ps1`) is consistent with Task 3's conventions file.

- [ ] **Step 3: Commit**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git add references/core.md && git commit -m "feat: core stack recipe reference"
```

---

### Task 3: `references/conventions.md` — cross-project conventions + CLAUDE.md template

**Files:**
- Create: `<root>\references\conventions.md`

**Interfaces:**
- Consumes: script/dir names defined in core.md (Task 2) — must match exactly.
- Produces: the project CLAUDE.md template used verbatim by skill runs.

- [ ] **Step 1: Write `references/conventions.md` with this exact content**

````markdown
# Cross-Project Conventions

These end the drift between projects (`_docs` vs `docs`, script naming,
etc.). Every new project follows all of them.

## Directory + naming

- `docs/` (never `_docs`). Specs: `docs/superpowers/specs/`. Plans: `docs/superpowers/plans/`.
- Dev scripts: `dev.sh` **and** `dev.ps1` (both, always — Windows dev machine, Linux servers).
- DB code: `db/` at repo root (`db/schema.ts`, `db/seed.ts`, `db/seed-admin.ts`).
- Feature code: `src/features/<feature>/` for domain logic; `src/app/` stays thin (routes + pages).

## Project CLAUDE.md template

Create `CLAUDE.md` at repo root with exactly these sections, filled in:

```markdown
# <Project Name>

<one-line purpose from intake>

## Stack

<one line: Next.js <ver> · React <ver> · Drizzle/Postgres · Better Auth · Tailwind v4 · shadcn[ · chosen modules]>

## Commands

- `./dev.sh` / `./dev.ps1` — dev DB + migrate + dev server
- `pnpm db:generate` / `db:migrate` / `db:seed` / `db:seed-admin`
- `pnpm lint` / `pnpm build`

## Source of truth

- `docs/` — specs and decisions. Where code and docs disagree, docs win.

## Conventions

- Feature code in `src/features/<feature>/`; `src/app/` stays thin.
- Conventional commits. Commit after every completed task.
- Every new env var goes into `.env.example` in the same commit that introduces it.
```

## Commit style

Conventional commits (`feat(scope): …`, `fix: …`, `docs: …`). First commit
of a new project: `feat: project foundation (<stack summary>, modules: <list or none>)`.

## .env.example discipline

- Every variable the app reads appears in `.env.example` — no exceptions.
- Placeholder values only, never real secrets. Each var gets a one-line
  `#` comment: what it is, where to get it.
- Baseline vars: `DATABASE_URL`, `BETTER_AUTH_SECRET`, `BETTER_AUTH_URL`,
  `SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD` (+ module vars per module file).

## README

Short: what the project is (purpose line), Getting started (the exact
command sequence that was verified in this run), pointer to `docs/`.
````

- [ ] **Step 2: Verify consistency**

Check: script names and `db/` layout match `references/core.md` exactly; the CLAUDE.md template contains no unfilled `<...>` slots other than ones the skill run fills (name, purpose, versions, modules).

- [ ] **Step 3: Commit**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git add references/conventions.md && git commit -m "feat: cross-project conventions reference"
```

---

### Task 4: `references/i18n.md` — optional module

**Files:**
- Create: `<root>\references\i18n.md`

**Interfaces:**
- Consumes: applied after core.md scaffold; must not rename anything core.md created.
- Produces: env/config additions the report step lists.

- [ ] **Step 1: Write `references/i18n.md` with this exact content**

````markdown
# Optional Module: i18n (next-intl)

Include at scaffold time when chosen — retrofitting locale routing later is
painful (every route moves under `[locale]`).

## Decisions

- Library: **next-intl**, current stable, with **locale-prefix routing** (`/et/...`, `/en/...`).
- Locales: `et` (default) and `en`. Estonian is the default locale for 3dlab-family projects unless the intake purpose clearly says otherwise.
- Messages: `messages/et.json`, `messages/en.json` at repo root. Nested keys by feature (`"auth.login.title"` style flat within feature namespaces).
- Follow next-intl's current official App Router setup guide (middleware + `[locale]` segment + plugin in next.config) — the API moves between majors, so read the docs at run time rather than assuming.

## Rules

- Every user-facing string goes through translations from day one — no hardcoded UI text, including the scaffold's minimal home page.
- Both locale files stay key-identical; missing keys are a lint-time error if next-intl's tooling supports it in the current version.
- `hreflang`/alternates: wire Next metadata alternates for the two locales on the root layout.

## Verification additions

- `/et` and `/en` both return HTTP 200 and render translated strings (check one known string differs between the two responses).
````

- [ ] **Step 2: Verify structure**

Check: ≤ 150 lines, no source-code blocks, locale set is exactly `et`/`en`.

- [ ] **Step 3: Commit**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git add references/i18n.md && git commit -m "feat: i18n optional module reference"
```

---

### Task 5: `references/storage-r2.md` — optional module

**Files:**
- Create: `<root>\references\storage-r2.md`

- [ ] **Step 1: Write `references/storage-r2.md` with this exact content**

````markdown
# Optional Module: Cloudflare R2 Storage

## Decisions

- Access R2 through its **S3-compatible API** with `@aws-sdk/client-s3` (+ `@aws-sdk/s3-request-presigner`).
- One client helper in `src/lib/storage.ts`; nothing else imports the AWS SDK directly.
- Upload pattern: server issues a **presigned PUT URL**; browser uploads directly to R2. Files never stream through the Next server.
- Object keys: `<feature>/<entityId>/<uuid>-<sanitized-filename>` — never trust the raw client filename.

## Env vars (add to .env.example with comments)

- `R2_ACCOUNT_ID` — Cloudflare account ID (dashboard → R2)
- `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` — R2 API token pair
- `R2_BUCKET` — bucket name
- `R2_PUBLIC_URL` — public bucket/custom-domain base URL, if the bucket is public

## Out of scope for the skill run

- Bucket creation, CORS rules on the bucket, and the API token are manual
  per-project steps in the Cloudflare dashboard. The report step must list
  them as pending setup.

## Verification additions

- None automated (no real bucket at scaffold time). Verify the helper
  module typechecks via `pnpm build`; real upload is proven with the first
  feature that uses it.
````

- [ ] **Step 2: Verify structure**

Check: ≤ 150 lines; env var names appear identically here and nowhere contradicted; explicitly lists manual steps for the report.

- [ ] **Step 3: Commit**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git add references/storage-r2.md && git commit -m "feat: R2 storage optional module reference"
```

---

### Task 6: `references/ai.md` — optional module

**Files:**
- Create: `<root>\references\ai.md`

- [ ] **Step 1: Write `references/ai.md` with this exact content**

````markdown
# Optional Module: Anthropic AI

## Decisions

- SDK: `@anthropic-ai/sdk`, current stable.
- One helper in `src/lib/ai.ts` owning the client + model constants; routes/features import from it, never construct their own client.
- **Model selection follows the global guide** in `~/.claude/CLAUDE.md` (Model Selection Guide): Sonnet default, Haiku for cheap/simple calls, Opus-tier only where error cost is high. Look up **current model IDs at run time** (the `claude-api` skill / Anthropic docs) — do not trust remembered IDs; families move.
- All AI calls happen server-side (route handlers / server actions). The API key never reaches the client bundle.
- Set an explicit `max_tokens` on every call; stream responses for anything user-facing.

## Env vars

- `ANTHROPIC_API_KEY` — from console.anthropic.com (comment this in .env.example)

## Verification additions

- Helper typechecks via `pnpm build`. If a key is present in `.env.local`, one smoke call with the cheapest model ("reply with OK") proves wiring; if no key, skip and list the key as pending in the report.
````

- [ ] **Step 2: Verify structure**

Check: ≤ 150 lines; contains the run-time model-ID lookup instruction (no hardcoded model IDs anywhere in the file).

- [ ] **Step 3: Commit**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git add references/ai.md && git commit -m "feat: Anthropic AI optional module reference"
```

---

### Task 7: `references/email.md` — optional module

**Files:**
- Create: `<root>\references\email.md`

- [ ] **Step 1: Write `references/email.md` with this exact content**

````markdown
# Optional Module: Brevo Transactional Email

## Decisions

- Call Brevo's transactional API (`https://api.brevo.com/v3/smtp/email`) via plain `fetch` from one helper in `src/lib/email.ts` — the official SDK is heavyweight and unnecessary for send-only use.
- Helper exposes intent-named functions (`sendVerificationEmail`, `sendPasswordResetEmail`), not a generic `sendEmail` free-for-all.
- Wire into Better Auth's email hooks: email verification + password reset if chosen together with the auth baseline.
- Dev behavior: when `BREVO_API_KEY` is unset, log the email payload to console instead of sending — signup must work locally without a key.

## Env vars (add to .env.example with comments)

- `BREVO_API_KEY` — Brevo dashboard → SMTP & API → API keys
- `EMAIL_FROM` — verified sender, e.g. `noreply@<domain>`
- `EMAIL_FROM_NAME` — display name

## Verification additions

- With no key set: signup flow still completes locally and the payload appears in the dev-server log (this IS the auth round-trip check plus one log assertion).
- Real send is proven when the project gets a domain + verified sender — list as pending in the report.
````

- [ ] **Step 2: Verify structure**

Check: ≤ 150 lines; dev fallback behavior (no key → console log) is stated; env vars commented.

- [ ] **Step 3: Commit**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git add references/email.md && git commit -m "feat: Brevo email optional module reference"
```

---

### Task 8: End-to-end validation run

**Files:**
- Create (throwaway): `<scratchpad>\e2e-newproj\` — a real skill run's output, **outside** `~/Documents`, then deleted
- Possibly modify: any `<root>` file where the run exposes a wrong/missing instruction

**Interfaces:**
- Consumes: the complete skill (Tasks 1–7).
- Produces: a validated skill; fixes committed.

- [ ] **Step 1: Dry-run the skill for real, in test mode**

Execute the `/new-project` flow exactly as SKILL.md says, with three test-mode deviations: project folder in the session scratchpad (not `~/Documents`), **skip step 4's `gh repo create`/push** (local git only), intake answered by the executor as: name `e2e-newproj`, purpose "throwaway skill validation", modules **i18n only**, private.

- [ ] **Step 2: Check the finish line**

All must hold: dev server 200 on `/et` and `/en`; migrate + seed + seed-admin clean; auth signup→login round-trip 2xx with session; `pnpm lint` exit 0; `pnpm build` exit 0; `docs/`, `CLAUDE.md`, `.env.example`, CI workflow, `dev.sh`/`dev.ps1`, Dockerfile all present and matching conventions.md.

- [ ] **Step 3: Fix the skill where the run stumbled**

Every place the executor had to guess, improvise, or fix something → update the corresponding `references/*.md` or `SKILL.md`. This is the skill's first maintenance-model iteration.

- [ ] **Step 4: Tear down**

Stop containers, remove the scratch project folder (it's in the scratchpad — disposable), remove the scratch Docker volume.

- [ ] **Step 5: Commit fixes**

```bash
cd "/c/Users/Rahi Lokotar/.claude/skills/new-project" && git add -A && git commit -m "fix: lessons from e2e validation run"
```

---

## Self-Review (completed at plan-writing time)

- **Spec coverage:** intake/scaffold/verify/commit/report flow → Task 1; core recipe + gotchas → Task 2; conventions + CLAUDE.md template → Task 3; four optional modules → Tasks 4–7; "verified" claim made real → Task 8; maintenance model → SKILL.md §Maintenance + Task 8 Step 3. Out-of-scope items (deploy, non-web, migration of old projects) appear in no task. ✓
- **Placeholder scan:** no TBDs; all file contents written in full. ✓
- **Consistency:** script names (`db:generate/migrate/seed/seed-admin`, `dev.sh`/`dev.ps1`), dir names (`db/`, `docs/superpowers/…`, `src/features/`), env var names, and the six reference filenames match across Tasks 1–7. ✓
