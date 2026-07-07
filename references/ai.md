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
