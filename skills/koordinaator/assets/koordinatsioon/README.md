# Koordinatsiooni protokoll — <PROJEKT>

Töö käib mitmes Claude sessioonis korraga: üks KOORDINAATOR (loeb,
mõõdab, jagab, kontrollib, liidab mandaadiga) ja töösessioonid (igaüks
üks haru, üks failihulk, üks PR). Rahi otsustab ja kinnitab iga
liitmise. Oskus `koordinaator` (Rahi kontol / `~/.claude/skills/`, MITTE selles
repos) kirjeldab rollid ja töövoo; see fail kannab PROJEKTI enda fakte.
See on protokolli aste 2 (kolm faili); väiksem projekt kasutab ühte
`SEIS.md`-d, mille sisu on siia üle tõstetud.

## 1. Failid

- `README.md` (see) — reeglid ja ops-faktid. Muudab koordinaator.
- `LAHTISED.md` — üks loend lahtistest asjadest: A Rahi käes, B käimas,
  C järjekorras. Rida = üks PR. Tehtud rida läbi kriipsutada, mitte
  kustutada, kuni järgmise koristuseni.
- `POSTKAST.md` — püsiv, ainult lisamine, üks plokk töö lõpus (mis
  tehtud, mis mõõdetud, mis lahtine). Loe iga sessiooni alguses viimased
  plokid. Vanem sisu arhiivi `POSTKAST-arhiiv-<kuupäevad>.md`.

## 2. Reeglid

1. Sessioon muudab ainult oma real olevaid faile (failiomand POSTKAST-i
   plokis). Võõras fail → „VAJAN: <fail> <mis>" plokk, ülejäänu tehakse.
2. Üks PR teeb ühe asja. Viimistlus ei kasvata koodi (`src/` netoread
   ≤ 0; tükeldamise liides ei loe). Funktsioon nimetab, mida lisab.
3. Käitumise samasus tõestatakse numbritega (kontrollid, mõõtmised
   enne/pärast, UI puhul pikslid), mitte sõnadega. PR ütleb: „see muudatus
   eeldab X, X on mõõdetud Y-ga". Ülevaataja esimene küsimus on alati:
   mida see muudatus eeldab ja kas keegi mõõtis seda?
4. Testid jooksevad fixture'ide vastu, mitte elusate teenuste vastu.
5. Iga kirjutav agent saab oma worktree. `git add -A` on keelatud;
   failid lisatakse nimepidi.
6. Mudeli nime ei kirjutata commitisse ega PR-i.
7. Liitmine ainult Rahi „jah" või mandaadi peale; pärast liitmist
   jälgib koordinaator deployd ja ütleb, mis commit on toodangus.
8. Mõõtmise lõksud: üks käik ei tõesta (mõõda sama koodi kaks korda,
   et müra põrand oleks teada); taimer ei ole sünkroon; tuletatud hulk
   (failid, testid), mis jääb tühjaks, peab kukkuma valjult, mitte
   läbima vaikselt; agendi raport ei ole tõend — mõõda mõõtmist.
9. Sõltuvuse lisamine on koordinaatori otsus: mõõdetud (paigaldub, suurus,
   API laeb), pinnitud versioon, promptis sõnaselgelt lubatud.
10. Reposse läheb ainult see, mida see projekt vajab ehitamiseks,
    testimiseks, käitamiseks ja mõistmiseks. Oskused, isiklikud
    tööriistad ja üleprojektilised protsessid elavad kontol, mitte siin.
    Enne iga push'i: `git diff --name-only` — kas iga fail on selle
    projekti oma ja kas puus ei ole midagi, mis sinna ei kuulu.

## 3. Ops-faktid (täida)

| Mis | Väärtus |
|---|---|
| Repo, põhiharu | `<omanik>/<repo>`, `main` |
| Deploy | <Coolify host, rakenduse uuid, auto-deploy push main-i peale> |
| Healthcheck / elus versioon | `<url, mis ütleb elus commiti>`, `<url, mis ütleb tervise>` — kui on |
| Kiired kontrollid | `<npm test / tsc / build …>` — mis on olemas; kui midagi ei ole, C1 on nende loomine |
| Keskkonna lõksud | <keskkonnamuutujad, mida testideks maha võtta; tööriistad, mida paigaldada ilma manifestita; brauseri tee — kui kehtivad> |
| Fixture'ide ulatus | <mis ala/andmed on kaetud> |
| Saladused | <kus elavad; MITTE KUNAGI vestlusse> |

## 4. Mõõdetud lõksud

Projekti omad siia (kuupäev, mis juhtus, mis reegel sündis). Üle
projektide korduvad on oskuse `references/oppetunnid.md`-s.
