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
| Sonnet 4.6 | `claude-sonnet-4-6` | Everyday coding, features, fixes |
| Opus 4.6 | `claude-opus-4-6` | Security, planning, hard problems |

## Where This Is Enforced

- **`~/.claude/CLAUDE.md`** — loaded globally in every Claude Code session on this machine
- **Project CLAUDE.md** — reinforced per-project where relevant
- This file is the source of truth for the rule set — update it here, then re-run `install.sh` to sync

## Adding to a New Machine

The install script (`install.sh`) does not currently copy `MODELS.md` into `~/.claude/CLAUDE.md` automatically — that step is done manually. After cloning the repo on a new machine, run:

```bash
cp ~/Documents/claude-setup/MODELS.md ~/.claude/CLAUDE.md
```

Or adapt `install.sh` to do it automatically.
