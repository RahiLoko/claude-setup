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
| `mkt-` | coreyhaines31/marketingskills | cold-email, page-cro, copywriting, launch-strategy, lead-magnets, seo-audit, + 29 more |
| `wondelai-` | wondelai/skills | hundred-million-offers (Hormozi), influence-psychology (Cialdini), storybrand, + 35 more |
| `founder-` | mfwarren/entrepreneur-claude-skills | cold-outreach, offer-creation, pricing-strategy, + 21 more |
| `oc-` | OpenClaudia/openclaudia-skills | seo-audit, write-blog, i18n, keyword-research, + 9 more |
| `impeccable-` | pbakaus/impeccable | polish, animate, audit, colorize, critique, typeset, + 15 more |
| `emilkowalski-skill` | emilkowalski/skill | Web animation + design engineering patterns |
| `design-auditor` | Ashutos1997/claude-design-auditor-skill | Scores UI against 18 design rules |
| `owasp-security` | agamm/claude-code-owasp | OWASP Top 10:2025 security review |
| `email-html-mjml` | framix-team/skill-email-html-mjml | Responsive HTML emails (requires `npm i -D mjml`) |
| `3dlab-blog-writer` | **custom** | 3dlab.ee MDX blog writer — frontmatter, bilingual ET/EN, image linking |
| `new-project` | **custom** | Bootstraps a verified new web project (Next.js + Drizzle/Postgres + Better Auth + Docker) |
| `resume` | **custom** | Session-start briefing from RESUME.md, plan, memory, git log |

## Custom skills

`skills/3dlab-blog-writer/` — Blog writer tuned for 3dlab.ee:
- Knows exact MDX frontmatter schema
- Bilingual fields (ET default, EN for Nordic posts)
- Rahi's writing voice (no buzzwords, first-person, real examples)
- Image placement in `/images/blog/{slug}/`
- Tag vocabulary: BIM, ArchiCAD, ÜBN, IFC...

**Usage:** Type `/3dlab-blog-writer`, paste your rough draft.

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
./install.sh   # re-runs everything, overwrites existing
```
