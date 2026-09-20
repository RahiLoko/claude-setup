# Keskkond: pilv vs kohalik

Sama töövoog, kaks tööriistakomplekti. Režiimi valib koordinaator
sessiooni alguses tööriistade järgi; Rahi käest ei küsita. Kõik
projektid on GitHubis, seega PR on alati olemas ja liitmine käib alati
PR-i kaudu — ka kohalikus režiimis ei liideta `git merge`-iga otse
`main`-i.

## Tuvastus

| Küsi endalt | pilv | kohalik |
|---|---|---|
| Kas `create_session` / `get_session` on tööriistade loendis? | jah | ei |
| Kas `Agent` tööriist on `isolation` parameetriga? | (ka) | jah |
| Kas `gh` on olemas ja sisse logitud (`gh auth status`)? | ei tarvitse | peab; kui ei ole → A-rida Rahile |

Kui ükski kahest ei ole (ei `create_session`, ei `Agent`): sa oled
üksi. Tee väikesed asjad ise harul ja PR-iga; suured ootavad; ütle
Rahile, et töösessioone selles keskkonnas ei saa.

## Pilv

```
create_session(
  title, model: "claude-opus-5",
  source_url: "https://github.com/<omanik>/<repo>",
  source_revision: "main",
  outcome_branch: "<haru>",
  tags: ["<projekt>:<teema>-<kuupäev>"],
  prompt: <sessiooni-mall.md järgi>)
```

- `permission_mode` jäta määramata (päritakse; lubavam keeldub).
- Kontroll: `send_later` 45–50 min pärast → `get_session` olek ja
  harud; sekku `create_trigger(persistent_session_id)` +
  `fire_trigger`-iga, kui sessioon läks valele teele.
- Sessioon avab PR-i ise; loa-küsimise taha peatunud sessiooni raport
  tuleb sama trigger-mehhanismiga.
- Hind: `get_session` → `usage.cost_usd` päevikusse.
- Liitmine: `merge_pull_request(merge_method: "merge", commit_title:
  "release: <mis> (#N)", expectedHeadSha: <40 märki>)`.

## Kohalik (Claude Code Desktop / terminal)

Töösessioon = `Agent` alamagent:

```
Agent(
  subagent_type: "general-purpose",
  model: "opus",            # kood; "sonnet" ainult mehaanika (mudelid.md)
  isolation: "worktree",    # oma worktree, oma indeks — KOHUSTUSLIK
  run_in_background: true,  # mitu paralleelselt
  description: "<haru>: <mis>",
  prompt: <sessiooni-mall.md järgi> + rida:
    "Sa oled oma worktree's. Loo haru `git checkout -b <haru>` (algab
     main-ist), commiti tükkhaaval, LÕPUS `git push -u origin <haru>`.
     ÄRA ava PR-i, ÄRA liida, ÄRA puutu teisi harusid.")
```

- Paralleelsus: käivita kõik sõltumatud alamagendid ÜHES sõnumis
  taustal; teavitus tuleb, kui igaüks lõpetab. Ära jookse neid
  järjestikku „et harud ei seguneks" — worktree lahendab selle.
- Blokeeriv väike töö (ümbernimetamine, mida kõik puutuvad): jäta
  viimaseks; teised alamagendid töötavad praeguste nimede peal ja
  käivituvad kohe. Kui see päriselt peab olema enne, tee ise, PR,
  „jah", liida — aga ära hoia teisi selle taga, kui saab vastupidi.
- Sama faili puutuvad asjad: kumbki oma uus moodul (`src/csv.mjs`,
  `src/report.mjs`), ühises failis üks import-rida; promptis öelda
  „ära muuda `<fail>`-i muid ridu". Konflikt on siis üherealine.
- Alamagent ei tohi töötada koordinaatori checkout'is: kui `isolation`
  puudub või ütleb „not in a git repository" (sessioon ei ole repo
  juurkaustas), loo ise `git worktree add /tmp/wt-<haru> -b <haru>
  main` ja ütle promptis absoluutne tee.
- Ka koordinaatori enda väike parandus: `git worktree add /tmp/wt-fix
  -b fix/<mis> main`, commit seal, `git push -u`, `gh pr create`, Rahi
  „jah", `gh pr merge`. Otse `main`-i ei commiti.
- Kontroll: alamagendi raport tuleb teavitusena; ära polli. Raport ei
  ole tõend — `git fetch`, oma worktree, kiired kontrollid ise.
- PR avab koordinaator: `gh pr create --base main --head <haru>
  --title "<tüüp>(<ala>): <mis>" --body-file <tõestused>`. Kehas on
  alamagendi mõõtmised JA sinu enda kontrolli tulemus eraldi ridadena.
- Hind: Agent-tulemuse `subagent_tokens` päevikusse.
- Liitmine (pärast „jah"): `scripts/liida-main.sh <haru>`, kontrollid,
  siis `gh pr merge <N> --merge --subject "release: <mis> (#N)"`.
  `--delete-branch` ainult, kui Rahi on öelnud, et harud võib kustutada.
- Deploy jälgimine: `scripts/deploy-seis.sh` või README ops-tabel; kui
  deploy'd ei ole, ütle „liidetud, deploy'd sellel projektil ei ole".

## Mis on mõlemas sama

- Üks haru `main`-ist, üks failihulk, failiomand protokollis enne
  käivitamist.
- Prompt sessiooni-mall.md järgi; mudeli nime ei kirjutata commitisse
  ega PR-i.
- PR-i kontroll (SKILL.md) enne Rahile toomist, ka enda PR-il.
- Liitmine ainult „jah"-i või mandaadi peale.
