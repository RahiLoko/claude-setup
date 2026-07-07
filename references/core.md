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
