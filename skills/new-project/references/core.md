# Core Stack Recipe

Write everything fresh with current stable versions. These are the locked
decisions and known pitfalls — not code to copy.

## Step 0: machine prerequisites (check before intake)

- `pnpm` on PATH (if missing: `npm install -g pnpm` — corepack needs admin on Windows).
- Docker daemon running (`docker version`) — required for the DB verification steps. If absent, tell the user up front that DB checks will be skipped and listed as pending.
- `gh auth status` OK — required for repo creation.

## Locked decisions

- Package manager: **pnpm**.
- `create-next-app@latest`: TypeScript, App Router, Tailwind, `src/` directory, no default import alias changes.
- UI: shadcn (`pnpm dlx shadcn@latest init`), components added on demand only — don't pre-install a component zoo (YAGNI).
- DB: Drizzle ORM + Postgres. Schema in `db/schema.ts` (repo root `db/`, not `src/`), `drizzle.config.ts` at root. Scripts: `db:generate`, `db:migrate`, `db:seed`, `db:seed-admin`.
- Auth: Better Auth, email/password baseline. Server config in `src/lib/auth.ts`, client in `src/lib/auth-client.ts`, route handler under `src/app/api/auth/[...all]/`. Production options proven in brickbox-new: `minPasswordLength: 12`; session `expiresIn` 30 d, `updateAge` 1 d, cookie cache 5 min.
- Seed admin from `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD` env vars (never hardcoded).
- Every project ships `/api/health` (200 JSON + cheap `SELECT 1`) — compose healthchecks and Coolify rolling deploys depend on it.
- Security headers via `headers()` in next.config (see scaffold step 9) + `poweredByHeader: false`. CSP is per-project, added when the app's needs are known.

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
8. `/api/health` route: 200 + `{ status: "ok" }` with a `SELECT 1` DB ping. Compose healthchecks target it with wget.
9. Security headers in next.config `headers()` (baseline from ybn40/ybn-app, all routes): HSTS `max-age=63072000; includeSubDomains; preload`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy: camera=(), microphone=(), geolocation=()`, `X-Frame-Options: SAMEORIGIN`.
10. Boot assertions in `src/instrumentation.ts` (taevakera pattern): runs once at server start; throw if production is missing required secrets (`DATABASE_URL`, `BETTER_AUTH_SECRET`) or has test-mode flags on against the live domain.
11. Production `Dockerfile` + `docker-compose.yml`:
    - Next.js **standalone output** (`output: 'standalone'` in next.config) — without it the Docker image balloons or fails.
    - Multi-stage build; final stage runs the standalone server as non-root, and **installs wget** (alpine has no curl; Coolify healthchecks need one of them).
    - Entrypoint script: run migrations, start the server in background, **poll `/api/health` until up** (optionally pre-warm key pages), then `wait` — Coolify keeps the old container serving until the new one is healthy → zero-downtime deploys (3dlab-ee/taevakera pattern).
    - Optional once live: a compose backup sidecar — daily `pg_dump | gzip` to R2, keep last 30 (brickbox-new pattern; see storage-r2.md).
12. Dev scripts: `dev.sh` and `dev.ps1` pair — both: start dev DB container, run migrations, start `pnpm dev`.
13. `docs/` skeleton + project `CLAUDE.md` per conventions.md.
14. CI: `.github/workflows/ci.yml` — on push/PR: pnpm install (with cache), `pnpm lint`, `pnpm build` with placeholder env vars (never real secrets in CI). Nothing else (no deploy, no test matrix) until the project earns it.

## Known gotchas (validated in the 2026-07 e2e run)

- **pnpm ≥10 blocks dependency build scripts**, which aborts `create-next-app`'s install. Fix: write `pnpm-workspace.yaml` with `allowBuilds:` entries set to `true` for `sharp`, `unrs-resolver`, `@parcel/watcher`, `@swc/core`, `esbuild`, then `pnpm install`. The `pnpm` field in package.json is **no longer read** — the workspace yaml is the only place.
- **shadcn CLI non-interactive init**: `pnpm dlx shadcn@latest init -y -b base -p nova`. `-b` picks the component base (`base` = Base UI, our default; `radix` the alternative); without `-p <preset>` it prompts for a theme even with `-y` (presets: nova, vega, maia, lyra, mira, luma, sera, rhea).
- **Better Auth schema generation is chicken-and-egg**: the CLI loads your auth config, which imports the db, which imports the schema it's generating. Fix: temp generation-only config with `drizzleAdapter({} as never, { provider: "pg" })`, `mkdir db` first (the CLI won't create the output dir), then `pnpm dlx @better-auth/cli@latest generate --config auth-gen.config.ts --output db/schema.ts -y`; delete the temp config after.
- **Env loading**: `drizzle.config.ts` loads dotenv with `{ path: [".env.local", ".env"] }`; seed scripts run via `tsx --env-file-if-exists=.env --env-file-if-exists=.env.local` so they work locally and in containers without either file.

## Known gotchas (from brickbox / taevakera / ybn / 3dlab)

- Tailwind v4 config lives in CSS (`@import "tailwindcss"` + `@theme`), not `tailwind.config.ts` — don't generate a v3-style config.
- Better Auth needs `BETTER_AUTH_SECRET` and a correct `BETTER_AUTH_URL`/base URL per environment; missing URL is the classic "works locally, breaks in Docker" bug.
- Drizzle migrations in CI/Docker need `DATABASE_URL` at build vs runtime kept straight: migrations run at **runtime** (entrypoint), never during `next build`.
- `next build` must not require a live DB. Any page that queries the DB must be dynamic (`export const dynamic = 'force-dynamic'`) or query at request time only.
- pnpm on Windows + Docker: ensure `.dockerignore` excludes `node_modules`, `.next`, `.git` — or builds are slow and images dirty.
- **Standalone output-tracing drops lazily-imported packages** (taevakera hit this with bcryptjs): if a package is only `import()`ed at runtime, copy it into the runner stage explicitly or import it statically.
- **Server Actions behind the Coolify proxy**: both apex and www hostnames must be in `experimental.serverActions.allowedOrigins`, or whichever one the browser used gets CSRF-blocked (3dlab-ee).
- **`drizzle-kit migrate` can hang on pooled/shared Postgres** (Neon etc.). Fallback proven in brickbox-new: a small idempotent runner script that reads the latest `db/migrations/*.sql`, splits on `--> statement-breakpoint`, and skips "already exists" errors.

## Verification commands (used by SKILL.md step 3)

- DB up: `docker compose -f docker-compose.dev.yml up -d --wait`
- Migrate + seed: `pnpm db:migrate && pnpm db:seed && pnpm db:seed-admin`
- Dev boot: start `pnpm dev` in background, then `curl -s -o /dev/null -w "%{http_code}" http://localhost:3000` → expect `200`
- Auth round-trip (adjust paths to the current Better Auth version's REST endpoints):
  sign-up POST then sign-in POST with a scratch email; expect 2xx and a session token/cookie on sign-in.
- `pnpm lint` → exit 0. `pnpm build` → exit 0.
