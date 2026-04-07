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

## Custom skills

`skills/3dlab-blog-writer/` — Blog writer tuned for 3dlab.ee:
- Knows exact MDX frontmatter schema
- Bilingual fields (ET default, EN for Nordic posts)
- Rahi's writing voice (no buzzwords, first-person, real examples)
- Image placement in `/images/blog/{slug}/`
- Tag vocabulary: BIM, ArchiCAD, ÜBN, IFC...

**Usage:** Type `/3dlab-blog-writer`, paste your rough draft.

## Adding new custom skills

```bash
mkdir -p skills/my-skill-name
# write your SKILL.md
git add skills/my-skill-name/SKILL.md
git commit -m "add my-skill-name skill"
git push
```

The install script automatically copies everything in `skills/` to `~/.claude/skills/`.

## Updating skills

```bash
cd ~/Documents/claude-setup
./install.sh   # re-runs everything, overwrites existing
```
