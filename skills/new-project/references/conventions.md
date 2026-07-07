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

## Cross-cutting rules (from ybn40's governance doc — the best of the family)

- **Estonian characters must round-trip**: any new parser, importer, or writer gets a UTF-8 spot-check with `õ ä ö ü` before it's considered done.
- **Docs move with changes**: update the nearest CLAUDE.md/README in the same commit that changes the behavior it describes. No volatile status assertions in docs — point at the source of truth instead.

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
