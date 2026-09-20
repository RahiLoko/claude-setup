# Liitmine ja deploy

## Mandaat

| Rahi ütleb | Mis on lubatud |
|---|---|
| „Jah" / „liida jah" (pärast „Kas liidan #N?") | liida #N |
| „liida jah" pärast loendit | liida loetletud PR-id |
| „mergei need ära ja vaata deployd" | liida loetletud, lahenda konfliktid, jälgi deployd, paranda deploy-katkestus eraldi PR-iga ja liida see ka |
| vaikus | ära liida; too PR-id kokkuvõttena ja küsi |

Mandaat ei laiene PR-idele, mida loendis ei olnud, ka siis, kui need on
samast teemast.

## Põhiharu

Loe `git symbolic-ref refs/remotes/origin/HEAD` või projekti README
ops-tabelist. Skriptid võtavad põhiharu argumendina; `main` on ainult
vaikeväärtus.

## Järjekord

Suurimad ja kõige rohkem faile puutuvad enne, väikesed parandused
pärast — nii lahendad konflikti üks kord, väikeste PR-ide harus.
Dokumendi-PR-id viimasena.

## Iga PR enne liitmist

```
bash scripts/liida-main.sh <haru> [repo] [worktree] [põhiharu]   # põhiharu harusse, protokollidokumentide konfliktid mõlemad pooled
cd <worktree>            # sõltuvused: sümlink või paigaldus AINULT worktree's, mitte kunagi git add
<kiired kontrollid>      # README ops-tabelist
git add <failid nimepidi>; git commit; git push
```

Konfliktid koodis ja testides lahenda käsitsi: loe mõlemad pooled,
säilita mõlema loogika (nt üks pool tõi uue abifunktsiooni, teine uue
importija — tulemus kasutab mõlemat). Pärast lahendust kiired kontrollid
UUESTI, sest lahendus on uus kood.

Liida pilves `merge_pull_request(merge_method: "merge", commit_title:
"release: <mis> (#N)", expectedHeadSha: <täis 40-märgiline sha>)`;
kohalikus režiimis `gh pr merge <N> --merge --subject "release: <mis>
(#N)"`.

## Pärast viimast liitmist

```
git fetch origin <põhiharu> && git checkout -B verify-main origin/<põhiharu>
git ls-tree origin/<põhiharu> | grep -c node_modules   # ja muu, mis puusse ei kuulu: peab olema 0
<kiired kontrollid + build>
```

Kui `git checkout` ütleb „local changes would be overwritten", ära
sunni — vaata, mis need on, ja `git checkout -- <fail>` või `git stash`
teadlikult. Kontrolli enne, et sihtharu puus ei ole faili, mis su
töökataloogi kataloogi asendaks (sümlink `node_modules` kustutas päris
kataloogi).

## Deploy

Kuidas deployd jälgida, on projekti README ops-tabelis (platvorm,
rakenduse tunnus, healthcheck, elus versiooni URL). Üldreegel: iga push
põhiharusse teeb oma deploy; mitu kiiret liitmist annab järjekorra, kus
vahepealsed võivad kukkuda ilma koodiveata — loeb viimane. Kukkunud
deploy logist otsi `ERROR`, `failed`, `exit code`; tavalised põhjused:
puus on fail, mis ei tohiks seal olla; kompileerimisviga, mida kohalik
kontroll ei näinud (seadistuse ulatus); puuduv keskkonnamuutuja.

Näide, Coolify (3DLab-i tavaline platvorm; token keskkonnamuutujas, ära
prindi):

```
GET /api/v1/deployments/applications/<uuid>   → {count, deployments[{deployment_uuid,status,commit}]}
GET /api/v1/deployments/<deployment_uuid>     → {status, commit, logs}
GET /api/v1/deploy?uuid=<uuid>&force=false     → käsitsi deploy
GET /api/v1/applications/<uuid>               → {status: "running:healthy"}
```

`scripts/deploy-seis.sh <host> <uuid> <commit-prefiks>` pollib kuni
`finished|failed|cancelled`.

## Pärast deployd Rahile

Üks sõnum: liidetud PR-id, toodangu versioon ja olek, põhiharu kontroll
(numbritega), mis läks valesti ja kelle viga, mis Rahil nüüd katsetada,
mis on järgmine.
