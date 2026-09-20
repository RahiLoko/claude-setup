# Töösessiooni prompti mall

Prompt on leping: kõik, mida sessioon ei tea, ta arvab ise, ja arvab
enamasti laiemalt, kui sa tahtsid. Seepärast on piirid ja tõestusnõuded
sama tähtsad kui ülesanne. Kirjuta iga osa; lühike on lubatud, puuduv
mitte. Projekti faktid (käsud, teed, lõksud) võta projekti README
ops-tabelist, mitte peast.

```
Töökeel eesti keel; kood ja kommentaarid inglise keeles. Loe kõigepealt
CLAUDE.md, docs/koordinatsioon/README.md (reeglid ja ops-faktid),
LAHTISED.md, POSTKAST.md viimased 3–4 plokki, <teemakohased docs>.

KONTEKST. <Mis on põhiharus täna teisiti kui dokumentides.>

RAHI SOOVID (kuupäev, sõna-sõnalt): „…"

KOORDINAATORI MÕÕTMISED: <numbrid, mida sa ise mõõtsid, koos
tingimustega (seade, keskkond, sisend). Sessioon alustab siit.>

ÜLESANNE, <N> ERALDI PR-i `<põhiharu>` vastu, igaüks oma harult:
PR 1 — haru `<nimi>` (seadistatud): <mis, kuhu, kuidas; otsused, mille
  sessioon ise teeb, ja nõue need PR-is välja öelda>
PR 2 — …

PIIRID. Sinu failid: <loend>. ÄRA puutu: <loend> — <kes seal töötab>.
Ära lisa sõltuvusi <või: „sõltuvus X@versioon on lubatud, muid mitte">,
ära muuda <manifest>/<ehituse seadistus>/CLAUDE.md; vajadus → POSTKAST
„VAJAN:" plokk. Netoread: liidese read ei ole kasv; funktsioon-PR
nimetab, mida lisab (README „Reeglid").

KESKKOND. <README ops-tabelist: kiired kontrollid; keskkonnamuutujad,
mida testideks maha võtta; tööriistad, mida paigaldada ilma manifesti
muutmata; fixture'ide/andmete ulatus; mida ei tohi (elusad teenused,
`rm -rf`, sümlingid puusse).>

TÕESTUS (PR-i kirjelduses numbritega): <kiired kontrollid; üks mõõtmine
enne/pärast, mida käsuga saab korrata; UI puhul kuvatõmmised/pikslid;
„see muudatus eeldab X, X on mõõdetud Y-ga">. Docs, mida uuendada: <…>.

PROTSESS. Commiti tükkhaaval, iga commit üks teema. Iga PR-i lõpus
POSTKAST.md ÜKS plokk (mis tehtud, mõõdetud, lahtine) ja LAHTISED.md
rida. PR pealkiri „<tüüp>(<ala>): <mis>". ÄRA liida PR-i ise —
koordinaator liidab Rahi mandaadiga. Ära kirjuta commitisse ega PR-i
mudeli nime. Kui kontekst hakkab täis saama, kirjuta seis POSTKAST-i ja
commiti kõik töökorras enne.

<Paralleelsed sessioonid: kes, mis failid, et ta neist eemale hoiaks.>
```

## Mida promptist välja jätta

- Lahendust ette kirjutamata ei jää, aga kirjuta see „otsusta ise, ütle
  PR-is miks" kujul, kui sul ei ole mõõdetud eelistust.
- Mudeli nimesid, tokeneid, saladusi.
- Faili sisu, mida sessioon saab ise lugeda.

## Sessiooni loomine

Pilves `create_session`, kohalikus režiimis `Agent` oma worktree's —
mõlema täpne kuju `keskkond.md`-s. Kohalikus režiimis lisa prompti
lõppu: „Sa oled oma worktree's. Loo haru `<haru>` main-ist, commiti
tükkhaaval, lõpus `git push -u origin <haru>`. ÄRA ava PR-i, ÄRA liida."


```
create_session(
  title, model: "claude-opus-5",
  source_url: "https://github.com/<omanik>/<repo>",
  source_revision: "<põhiharu>",
  outcome_branch: "<haru>",
  tags: ["<projekt>:<teema>-<kuupäev>"],
  prompt: <ülal>)
```

`permission_mode` jäta määramata (päritakse; lubavam režiim keeldub).
`model`: kood → `claude-opus-5` (mõõdetud 19–52 $ PR-i kohta);
mehaaniline töö (tekst, docs, audit, skripti jooksutamine) →
`claude-sonnet-5` esimesena, ja POSTKAST-i kirja, kas tõestus läbi läks.
Vt `mudelid.md`. Pärast sessiooni lõppu `get_session` → `usage.cost_usd`
POSTKAST-i plokki. Kui sessioon peatub loa-küsimise taha, käivita tema
raport `create_trigger(persistent_session_id) + fire_trigger`-iga.

## Sekkumine

Kui `get_session` olek näitab midagi, mida ei palutud („planning X
refactor"), saada kohe täpsustus sama trigger-mehhanismiga. Odavam kui
hiljem PR tagasi lükata.
