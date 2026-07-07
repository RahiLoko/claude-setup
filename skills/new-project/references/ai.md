# Optional Module: Anthropic AI

## Decisions

- SDK: `@anthropic-ai/sdk`, current stable.
- One helper in `src/lib/ai.ts` owning the client + model constants; routes/features import from it, never construct their own client.
- **Model selection follows the global guide** in `~/.claude/CLAUDE.md` (Model Selection Guide): Sonnet default, Haiku for cheap/simple calls, Opus-tier only where error cost is high. Look up **current model IDs at run time** (the `claude-api` skill / Anthropic docs) — do not trust remembered IDs; families move.
- All AI calls happen server-side (route handlers / server actions). The API key never reaches the client bundle.
- Set an explicit `max_tokens` on every call; stream responses for anything user-facing.
- **Validate AI output before it leaves the server** (3dlab-ee pattern): when model text goes into emails or pages, run a safety check that rejects URLs, email addresses, HTML tags, and phishing-ish phrasing.
- **Rate-limit any public endpoint that triggers an AI call** per IP (e.g. max 3 per 10 min for a contact form) — cost and abuse control.

## Env vars

- `ANTHROPIC_API_KEY` — from console.anthropic.com (comment this in .env.example)

## Verification additions

- Helper typechecks via `pnpm build`. If a key is present in `.env.local`, one smoke call with the cheapest model ("reply with OK") proves wiring; if no key, skip and list the key as pending in the report.
