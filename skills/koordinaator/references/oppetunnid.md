# Mõõdetud lõksud üle projektide

Need on maksma läinud. Projektipõhised lõksud on projekti `CLAUDE.md`
ja `docs/koordinatsioon/README.md` all; siin on need, mis korduvad
sõltumata projektist.

## Keskkond (pilvesessioon)

- Konteineri keskkonnamuutujad (deploy-platvormi token, tootmise URL)
  võivad panna rakenduse „olen toodangus" režiimi: kohalik proovirežiim
  ja osa teste keelduvad. Nimeta need projekti README ops-tabelis ja
  igas sessiooni promptis (`env -u <muutuja> …`), muidu raporteerib
  sessioon kukkunud teste, mis ei ole tema omad.
- Tööriist, mida manifestis ei ole (nt brauseriautomaatika), paigalda
  ilma manifesti muutmata (`npm i --no-save`); ette paigaldatud brauseri
  tee on README-s.
- Proxy võib keelata osa git-operatsioone (`push --delete`) ja väliseid
  hoste; harud kustutab Rahi ise.
- Ajastustundlikud testid kukuvad, kui mitu testikomplekti jooksevad
  korraga samal masinal. Kukkunud test üksi uuesti → roheline = koormus,
  mitte kood.
- `sleep N` ootamiseks ei ole lubatud; kasuta `until <tingimus>; do sleep
  2; done` või taustatööd.

## Mis kuulub reposse

- Projekti repo = see, mida see projekt vajab ehitamiseks, testimiseks,
  käitamiseks ja mõistmiseks. Ei kuulu: Rahi kontole mõeldud oskused,
  isiklikud skriptid, üleprojektilised protsessid — need on `.skill`
  fail või üleprojektiline koht. Mõõdetud 06.09.2026: koordinaator avas
  oskuse kaardirepo PR-iks (#201), Rahi küsis tagasi. Kontroll: PR-i
  kontrolli samm 0 (SKILL.md), ka enda PR-idel.
- Sama viga teises kuues: konfliktilahenduse commit tõi puusse
  worktree' sümlingi. Ühine juur: „pushin enne, kui vaatan, mis puus
  on". Kontroll: `git diff --name-only` ja `git ls-tree` ENNE iga push'i,
  mitte pärast.

## Git ja worktree'd

- Iga kirjutav agent saab OMA worktree. Ühine indeks tähendab, et
  `git commit` võtab kaasa teise agendi staged failid.
- Worktree's sõltuvuste sümlink (`node_modules` vms) on mugav, aga
  `git add -A` commitib sümlingi, kui ignoreerimisreegel on kaldkriipsuga
  (`node_modules/` sobitab ainult kataloogi). Ehitus kukub („cannot
  replace to directory … with file"). Reegel: ignoreerimisrida ilma
  kaldkriipsuta ja `git add <fail>` nimepidi.
- `git checkout` harusse, mille puus ON see sümlink, asendab päris
  kataloogi endasse osutava lingiga — kataloog on läinud, paigaldus
  tagasi. Kontrolli enne: `git ls-tree origin/<põhiharu> | grep
  node_modules` = 0.
- Konfliktid protokollidokumentides (POSTKAST, LAHTISED): mõlemad plokid
  jäävad (haru pool pärast põhiharu). Tabelis jälgi, et rida ei kaoks
  kahe ploki vahele.
- `merge_pull_request` tahab 40-märgilist `expectedHeadSha`-d.
- Liidetud PR-i haru ei kasutata uuesti: `git checkout -B <haru>
  origin/<põhiharu>` ja `--force-with-lease`.

## Testid ja tõestus

- Lähtekoodi lugev test (grep) väidab kirjapilti, mitte käitumist; ta
  läheb iga tükeldamise peale katki ja võib vaikselt tühjaks jääda.
  Tuletatud hulk peab kukkuma, kui ta jääb alla ootuse.
- „Flake" ei ole juurpõhjus. Kordusjooks ainult üks kord ja ainult
  kinnituseks.
- Sessiooni „kõik rohelised" ei ole tõend; jooksuta ise.
- Võrdlus ilma müra põrandata (sama kood, kaks käiku) ei ütle midagi;
  graafika ja animatsioon erinevad ka ilma muudatuseta.

## Hind

- Alamagent (Agent tool) pärib koordinaatori mudeli, kui `model` on
  määramata. 06.09 jooksid neli oskuseproovi Fable 5.1 peal, kuigi
  Sonnet oleks sama teinud. Otsing, lugemine, hindamine: `model:
  "sonnet"` või `"haiku"`.
- Koordinaatori 487 k kontekst maksis kahe päevaga 282 $, millest ~180 $
  oli vahemälu kirjutus ja lugemine. Kontekst on kulu; uus päev = uus
  sessioon POSTKAST-i seisu pealt.
- Iga `send_later` ärkamine loeb kogu konteksti. Kontroll, mis midagi ei
  leia, maksab sama palju kui see, mis leiab.

- Protokolli paigaldus olemasolevale väikesele projektile maksis
  proovis +240 s ja +40 % tokeneid ühe veaparanduse kõrval (mõõdetud
  06.09, oskusega 633 s / 113 k vs ilma 392 s / 81 k). See on ühekordne
  hind, mis tasub end ära alles teise sessiooni juures — ütle Rahile, et
  esimene käik on kallim, ära vaiki.

## Sessioonid

- `create_session` nõuab `source_url`-i, kui `outcome_branch` on antud. `permission_mode` ei tohi olla
  vanemast lubavam — jäta määramata.
- Sessioon võib peatuda loa-küsimise taha: tema raport tuleb kätte
  `create_trigger(persistent_session_id)` + `fire_trigger`-iga.
- Sessioon laieneb ise („planning X refactor"), kui piirid ei ole
  failinimede täpsusega kirjas. Kirjuta „ÄRA puutu" loend.
- Kaks sessiooni samas kaustas uute failidega: anna kummalegi OMA
  alamkaust, muidu nimed põrkuvad.
- Sessioon, kellele on öeldud „ära lisa sõltuvusi", jääb ummikusse, kui
  ülesanne ise on sõltuvus. Koordinaator otsustab ja lubab nimepidi.

## Kohalik režiim (Agent-alamagendid)

- Mõõdetud 06.09.2026 (v5 ilma keskkonnajuhiseta): koordinaator
  käivitas alamagendid samas checkout'is järjestikku ja lasi harudel
  üksteise peale ehitada, „et harud ei seguneks". Tulemus: kolm haru,
  mida saab liita ainult järjekorras, ja null paralleelsust. Kontroll:
  `isolation: "worktree"` igal kirjutaval alamagendil; iga haru
  `main`-ist; blokeeriv väike töö ise enne.
- Sama proov: alamagent commitis genereeritud väljundi (`report.html`)
  reposse. Kontroll: PR-i kontrolli samm 1 — genereeritud väljund, mida
  keegi ei palunud, ei kuulu puusse.
- Alamagendi raport tuleb teavitusena, kui `run_in_background: true`;
  pollimine on raisatud kontekst.

## Rahi

- Ta kontrollib päris seadmes ja ütleb, mis on katki, mitte miks.
  Mõõda põhjus enne, kui parandad. Emulatsioon ei kinnita ega lükka
  ümber seadme leidu: kui sinu mõõtmine ütleb „töötab", ütle see välja
  ja küsi a/b, mitte ära paranda oletust.
- Ta ei loe faile: iga „vaata failist" on sinu viga.
- Saladused (token ekraanipildil) — ütle kohe, et vahetada, ja kuhu uus
  panna (platvormi saladuste hoidla, mitte keskkonnamuutuja vestluses).
- Mudeli nime ei kirjutata commitisse ega PR-i; vestluses tohib.
- Ta kordab, kui ta ei saanud vastust, mida ootas („aga mida see
  tähendab?") — siis vasta konkreetse näitega, mitte sama määratlusega.
