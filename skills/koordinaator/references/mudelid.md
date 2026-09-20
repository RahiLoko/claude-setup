# Mudelite kasutus ja hind

Hind ei ole sessiooni hind, vaid VALMIS TÜKI hind: PR, mis on liidetud ja
toodangus. Odav sessioon, mis vajab teist ringi, ei ole odav. Aga sama
tulemuse võib saada poole hinnaga, kui kontekst on lühem, mudel on
ülesandele vastav ja mõõtmisi ei korrata asjata.

## Hinnad (Anthropic API, vahemälu 2026-06-24; kontrolli `claude-api` oskusest)

| Mudel | ID | Sisend $/M | Väljund $/M | Kus kasutada |
|---|---|---|---|---|
| Fable 5.1 | `claude-fable-5-1` | 10 | 50 | koordinaatori OTSUSTUSPÄEV (ülevaatus, disain, riskihinnang) — Rahi valik |
| Opus 5 | `claude-opus-5` | 5 | 25 | töösessioonid: refaktor, funktsioon, mõõtmisega veaparandus; koordinaator tavapäeval |
| Sonnet 5 | `claude-sonnet-5` | 2 | 10 | mehaaniline töö: tekstivahetus, docs kolimine, kuvatõmmiste audit, mõõteskripti jooksutamine; koordinaatori alamagendid, mis loevad |
| Haiku 4.5 | `claude-haiku-4-5` | 1 | 5 | alamagendid: otsing, faililoend, grep-kokkuvõte, hindamine skeemi järgi |

Vahemälu (prompt cache): kirjutus ~1,25× sisend, lugemine ~0,1× sisend
(Fable 5.1 lugemine 0,25 $/M). Pikk kontekst maksab iga käigu peal
uuesti — lugemisena odavalt, aga iga UUS tükk kirjutatakse vahemällu
täishinnaga.

## Mõõdetud 05.–06.09.2026 (ruumiandmed)

| Sessioon | Mudel | Kestus | Hind | Tulemus |
|---|---|---|---|---|
| Koordinaator (2 päeva, effort max, kontekst 487 k) | Fable 5.1 | ~30 h | **282 $** | 20 PR-i liidetud, 3 sessiooni juhitud, oskus |
| Tooriist tükkideks | Opus 5 | 1 h 15 | 52 $ | 1 PR, 3448 → 969 rida |
| KaartLive tükkideks | Opus 5 | 1 h 30 | 37 $ | 1 PR, 5693 → 346 rida |
| CSS esseed docs-i | Opus 5 | 1 h | 24 $ | 1 PR |
| Kõrgusjooned + tabamisala | Opus 5 | 1 h | 19 $ | 1 PR, 2 viga |
| 4 oskuse proovi alamagentidena | Fable 5.1 (päritud!) | 5–10 min | ~100–150 k tokenit igaüks | oleks pidanud olema Sonnet |
| Kohalik koordinaator (Agent-alamagendid, 3 haru, 60-realine projekt) | Sonnet 4.6 koordinaator + 3× Sonnet | 12,6 min | 119 k tokenit kokku | 3 haru valmis, testid 3/3; aga funktsioonid Sonnetil ja harud üksteise peale |

Koordinaatori 282 $ jaguneb: vahemälu kirjutus ~120 $, lugemine ~60 $,
väljund ~47 $ (effort max = pikk mõtlemine). Ehk suurim kulu on
KONTEKSTI KASV, mitte vastused. Iga töösessioon maksis 19–52 $ ja andis
ühe liidetud PR-i — see on mõistlik; koordinaatori kulu on see, mida
saab poole võrra alla tuua.

## Millal Sonnet, millal Opus, millal Fable

Kolm küsimust töö kohta, järjekorras:

1. **Kas viga siin maksab nädalaid?** (arhitektuur, mida hiljem ei
   pöörata; otsus, mis läheb reegliks; riskihinnang; suure refaktori
   ülevaatus) → **Fable 5.1**. Fable ei TEE, Fable OTSUSTAB ja HINDAB.
2. **Kas töö LISAB või MUUDAB käitumist?** (funktsioon, aruanne,
   import, veaparandus leidmata põhjusega) → **Opus 5**. **Sonnet 5**
   AINULT, kui muudatuse saab kirjeldada ühe lausega ilma ühegi
   disainiotsuseta: ümbernimetamine, tekst, konfig, docs kolimine,
   teadaolev üherealine parandus olemasoleva testiga. „Masinaga
   tõestatav" EI ole Sonneti kriteerium — ka funktsioon on masinaga
   tõestatav (mõõdetud 06.09: see sõnastus viis HTML-aruande ja
   CSV-impordi Sonnetile). Kukkunud tõestus = Opus teeb uuesti, ja
   päevik saab rea „Sonnet ei saanud X-iga hakkama".
3. **Kas töö on lugemine, mitte otsustamine?** (otsi, loenda, grep,
   hinda skeemi järgi) → **Haiku 4.5** alamagent; **Sonnet 5**, kui
   lugeja peab ka natuke aru saama.

| Töö | Mudel | Miks |
|---|---|---|
| Idee otsuseleht, suur plaan, arhitektuur, tehnilise valiku ettepanek | Fable 5.1 | vale valik maksab nädalaid; see on projekti kalleim otsus |
| Ülesannete kirjutamine sessioonidele (prompt, piirid, failiomand, tõestusnõuded) | Opus 5 | otsustus skoobi üle, aga tagasipööratav — prompt on odav parandada |
| Koordineerimine tavapäeval: seis, kontrollid, liitmine, konfliktid, deploy | Opus 5 (high) | rutiin, pool Fable'i hinnast; 06.09 mõõdetud 282 $ Fable max-iga |
| Suure PR-i sisuline ülevaatus (refaktor, uus arhitektuur, turvalisus) | Fable 5.1 | siin tasub tugevam pilk; väikese PR-i ülevaatus jääb Opusele |
| Kodeerimine: funktsioon, refaktor, veaparandus, mille põhjus on leidmata | Opus 5 | mõõdetud 19–52 $ PR-i kohta, tõestused läksid läbi |
| Kodeerimine: ette kirjutatud muutus (tekst, konfig, docs kolimine, teadaoleva vea parandus koos testiga) | Sonnet 5 | 2,5× odavam; tõestus näitab, kas piisas |
| Uurimine: „kus see koodis on", loendid, sõltuvused, grep-kokkuvõte | Haiku 4.5 alamagent | lugemine ilma otsustamiseta |
| Uurimine: „miks see viga tekib", „milline lahendus" | Opus 5 | vajab otsustust ja mõõtmise kavandamist |
| Mõõtmine olemasoleva skriptiga (pikslid, Playwright, audit) | Sonnet 5 | mehaaniline; skripti KAVANDAMINE on Opus |
| Hindamine skeemi järgi (testide tulemus, eval, checklist) | Haiku 4.5 | odav ja piisav |
| Ops: deploy logi, keskkond, mount, kukkunud build | Opus 5 | vea juurimine on otsustus |
| Dokumentatsioon, POSTKAST/LAHTISED koristus, arhiveerimine | Sonnet 5 | mehaaniline |
| Turvalisuse ülevaatus, litsentsi- ja õigusküsimuse hinnang | Fable 5.1 | viga maksab rohkem kui sessioon |

Kohalikus režiimis: `Agent(model: "opus")` koodile, `"sonnet"`/`"haiku"`
lugemisele; hind on tulemuse `subagent_tokens`. Effort: töösessioonil ei
saa seda `create_session`-iga määrata — prompt
otsustab (täpne ülesanne = vähem uurimist). Koordinaatoril määrab Rahi
UI-s: `high` tavapäeval, `max` otsustuspäeval.

## Suhe `~/.claude/CLAUDE.md` üldreegliga

Rahi üldine mudelijuhis ja see oskus ütlevad sama asja (kooskõlla
viidud 06.09.2026): Sonnet ainult ühe lausega kirjeldatav muutus ilma
disainiotsuseta; kõik, mis lisab või muudab käitumist → Opus. Kui
kunagi näed, et need erinevad, kehtib see oskus (mõõdetud) ja ütle
Rahile ühe reaga, et üldfail vajab uuendust.

## Reeglid

1. **Töösessioon = Opus 5, kui töö on kood.** Mõõdetud 19–52 $ PR-i
   kohta. Fable töösessioonile ei anta (2× hind, sama töö).
2. **Mehaaniline töö = Sonnet 5, esimene katse.** Tekstivahetus, docs
   kolimine, auditi skript, kuvatõmmised. Kui tõestus ei tule läbi,
   siis Opus. Kirjuta POSTKAST-i, kumb läbi läks — see tabel otsustab
   järgmise korra, mitte arvamus.
3. **Alamagendid (Agent tool) saavad `model: "sonnet"` või `"haiku"`.**
   Otsing, lugemine, grep, hindamine. Ilma parameetrita pärivad nad
   koordinaatori mudeli — 06.09 jooksid neli oskuseproovi Fable'il.
4. **Koordinaatori kontekst on kulu.** Ära loe suuri faile ise (anna
   Explore-alamagendile), ära kleebi PR-ide kehasid, ära hoia
   proovi-skripte vestluses. Kui kontekst > 300 k tokenit või uus päev:
   kirjuta seis POSTKAST-i ja alusta koordinaatorina uus sessioon —
   odavam kui 400 k konteksti iga käigu peal edasi tassida.
5. **Koordinaatori mudel ja effort on Rahi otsus, numbritega:** Fable
   5.1 effort max = 282 $ / 2 päeva; Opus 5 effort high oleks hinnanguliselt
   ~1/3 sellest sama töö peale (pool hinnast, lühem mõtlemine). Soovitus:
   tavapäev Opus 5 high, otsustuspäev (disain, ülevaatus, riskid) Fable.
6. **Üks sessioon, mitu PR-i**, kui PR-id jagavad konteksti (sama ala,
   samad docs). Külm sessioon loeb protokolli iga kord (POSTKAST 1600
   rida = ~40 k tokenit enne esimest tööd). Paralleelsed sessioonid
   säästavad AEGA, mitte raha — kasuta, kui Rahi ootab.
7. **POSTKAST arhiivi**, kui ta ületab ~600 rida. Iga sessioon loeb
   viimaseid plokke; vana ajalugu on arhiivifail, mida loetakse vajadusel.
8. **Tõestused korra, mitte kolm korda.** Fixture'i build üks kord haru
   kohta; pikslivõrdlus 2 käiku (müra põrand) + 1 võrdlus; jõudlusmõõdik
   3+3 ainult siis, kui PR puutub renderdusteed. Ülejäänu on raha
   kindlustunde eest, mida number juba andis.
9. **Kontrollid harvemini, kui midagi ei muutu.** Iga `send_later`
   ärkamine on täiskonteksti lugemine. 45–60 min, kui sessioonid
   töötavad; PR-sündmused (`subscribe_pr_activity`) on odavamad kui
   pollimine.
10. **Hind kirja.** Pärast iga sessiooni: `get_session` →
    `usage.cost_usd` (pilv) või `subagent_tokens` (kohalik) päevikusse koos tulemusega (PR-e, ridu,
    vigu). Kümne sessiooni järel on tabel, mis ütleb, mis mudel mis tööd
    tegema peab — mõõdetud, mitte arvatud.

## Mida see EI tähenda

- Odavaim mudel ei ole eesmärk. Kood, mille tõestus läbi ei lähe, tuleb
  teha uuesti, ja teine ring maksab rohkem kui esimene õige.
- Koordinaatori ülevaatus (tõestuste lugemine, konfliktide lahendus,
  deploy-vea juurimine) on koht, kus tugevam mudel tasub ennast ära —
  seal ei säästeta.
