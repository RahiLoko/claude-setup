# Claude Code Setup

My personal Claude Code skills and configuration.

## Install on a new machine

```bash
git clone https://github.com/RahiLoko/claude-setup ~/Documents/claude-setup
cd ~/Documents/claude-setup
chmod +x install.sh
./install.sh
```

Then restart Claude Code and run the `/plugin install` commands shown at the end of the script.

## What gets installed

| Prefix | Source | Skills |
|--------|--------|--------|
| `mkt-` | coreyhaines31/marketingskills | cold-email, cro, copywriting, launch, lead-magnets, seo-audit, + 40 more |
| `wondelai-` | wondelai/skills | hundred-million-offers (Hormozi), influence-psychology (Cialdini), storybrand, + 40 more |
| `founder-` | mfwarren/entrepreneur-claude-skills | cold-outreach, offer-creation, pricing-strategy, + 21 more |
| `oc-` | OpenClaudia/openclaudia-skills | seo-audit, write-blog, i18n, keyword-research, + 9 more |
| `impeccable` | pbakaus/impeccable | One umbrella design skill (shape, critique, polish, animate, …) + `reference/` + `scripts/` |
| `emilkowalski-skill` | emilkowalski/skill | Web animation + design engineering patterns |
| `design-auditor` | Ashutos1997/claude-design-auditor-skill | Scores UI against 19 design rules |
| `owasp-security` | agamm/claude-code-owasp | OWASP Top 10:2025 security review |
| `email-html-mjml` | framix-team/skill-email-html-mjml | Responsive HTML emails (requires `npm i -D mjml`) |
| `new-project` | **custom** | Bootstraps a verified new web project (Next.js + Drizzle/Postgres + Better Auth + Docker) |
| `resume` | **custom** | Session-start briefing from RESUME.md, plan, memory, git log |

Skills ship supporting files (`reference/`, `scripts/`, `docs/`), and the installer
copies those alongside `SKILL.md` — a skill installed as a lone `SKILL.md` is a
skill whose own instructions point at files that don't exist.

## Custom skills

> Project-specific skills live in their own repos, not here — e.g. the 3dlab
> blog writer is at `3dlab-ee/.claude/skills/3dlab-blog-writer`. This repo
> holds only skills that apply on any machine, in any project.

`skills/new-project/` — Project bootstrapper (instructions-only, no frozen code):
- One intake round (name, purpose, modules: i18n / R2 / AI / email), then autonomous
- Fixed stack: Next.js + Tailwind/shadcn (Base UI), Drizzle + Postgres, Better Auth, Docker/Coolify
- Verifies with evidence: dev server, migrate + seed, auth round-trip, lint, build — then creates the GitHub repo
- `references/*.md` hold the accumulated gotchas from live projects; lessons from each new project go back into them
- Design spec + plan live in `skills/new-project/docs/`

**Usage:** Type `/new-project`.

**Maintenance note:** on the main dev machine `~/.claude/skills/new-project` is a
junction into this repo, so editing the live skill edits the repo — commit and
push from here. Other machines get plain copies via `install.sh` and should not
edit locally.

## Adding new custom skills

```bash
mkdir -p skills/my-skill-name
# write your SKILL.md
git add skills/my-skill-name/SKILL.md
git commit -m "add my-skill-name skill"
git push
```

The install script automatically copies everything in `skills/` to `~/.claude/skills/`.

## Model selection

See [`MODELS.md`](MODELS.md) for the full model selection guide (Haiku / Sonnet / Opus).

The install script copies `MODELS.md` to `~/.claude/CLAUDE.md` so these rules are loaded globally in every Claude Code session.

## Updating skills

```bash
cd ~/Documents/claude-setup
./install.sh   # re-runs everything; safe to run repeatedly
```

`install.sh` is idempotent. Running it twice in a row leaves `~/.claude/CLAUDE.md`
and `~/.claude/settings.json` byte-for-byte identical.

## What install.sh touches

| Path | Behaviour |
|------|-----------|
| `~/.claude/skills/<name>/` | Overwritten for every skill it manages |
| `~/.claude/skills/.manifest` | List of skills this script installed |
| `~/.claude/CLAUDE.md` | **Managed block only** — see `MODELS.md`. Backed up to `CLAUDE.md.bak` |
| `~/.claude/settings.json` | Adds the SessionStart hook if absent. Backed up to `settings.json.bak` |

**Pruning.** When an upstream repo renames a skill (`mkt-page-cro` → `mkt-cro`),
the old directory is removed on the next run — but *only* if `.manifest` records
that this script installed it. Skills you added by other means are never in the
manifest, so they are never touched.

**Your global instructions are safe.** The installer never overwrites
`~/.claude/CLAUDE.md` wholesale; it syncs `MODELS.md` into a delimited block and
leaves everything else alone.
