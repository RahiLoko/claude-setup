# Model Selection Guide

Haiku ≈ 10–20× cheaper than Opus. Match model to task complexity and cost-of-failure.

## Quick Decision Table

| Use **Haiku** | Use **Sonnet** (default) | Use **Opus** |
|---------------|--------------------------|--------------|
| File reads & grep lookups | Feature development | Security-sensitive code |
| Codebase exploration | Bug fixes (routine) | Hard debugging (> 2 Sonnet attempts) |
| Translation string checks | UI component implementation | Architecture decisions |
| Summarizing logs/output | Code refactoring | Writing/reviewing implementation plans |
| Simple Q&A about existing code | Writing i18n strings | Complex multi-system reasoning |
| Formatting & linting checks | Most day-to-day coding | Anything where error cost is high |
| Regex / search patterns | PR descriptions & commit messages | Ambiguous tasks with high stakes |

## Rules

1. **Default to Sonnet.** If a task isn't clearly Haiku or Opus, use Sonnet.
2. **Haiku for subagents doing research.** Explore, search, summarize → `model: "haiku"`.
3. **Sonnet for subagents doing implementation.** Write code, refactor → `model: "sonnet"`.
4. **Opus for subagents doing security or planning.** Security review, plan writing, hard debugging → `model: "opus"`.
5. **Escalate to Opus if Sonnet fails twice** on the same problem. Don't retry the same model indefinitely.
6. **Never use Opus for lookups.** Reading files, grepping, summarizing is always Haiku or Sonnet.

## Model IDs

| Model | ID | Best for |
|-------|----|----------|
| Haiku 4.5 | `claude-haiku-4-5-20251001` | Research, lookups, fast agents |
| Sonnet 5 | `claude-sonnet-5` | Everyday coding, features, fixes |
| Opus 4.8 | `claude-opus-4-8` | Security, planning, hard problems |

The current frontier families are Claude 5 (`claude-sonnet-5`, `claude-fable-5`),
Opus 4.8, and Haiku 4.5. When building anything against the Claude API, default
to the latest and most capable model rather than pinning an old snapshot.

## Where This Is Enforced

- **`~/.claude/CLAUDE.md`** — loaded globally in every Claude Code session on this machine
- **Project CLAUDE.md** — reinforced per-project where relevant
- This file is the source of truth for the rule set — update it here, then re-run `install.sh` to sync

## How It Reaches `~/.claude/CLAUDE.md`

`install.sh` syncs this file into a **managed block** in `~/.claude/CLAUDE.md`,
delimited by a pair of HTML comments reading `BEGIN claude-setup:models` and
`END claude-setup:models`. (The literal marker text is deliberately not repeated
here — this file is pasted *inside* those markers, and a second copy of them in
the body would confuse the sync.)

Anything you write outside that block is yours and is never touched. Re-running
`install.sh` rewrites only the block, so editing `MODELS.md` here and re-running
is the correct way to update the rules everywhere.

If `~/.claude/CLAUDE.md` does not exist yet (fresh machine), the installer
creates it containing just the managed block. If it does exist, the installer
takes a `CLAUDE.md.bak` snapshot before modifying it.

> Do not `cp MODELS.md ~/.claude/CLAUDE.md`. That overwrites the whole file and
> destroys any hand-written global instructions living alongside the block.
