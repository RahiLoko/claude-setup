# Koordinatsioon — <PROJEKT> (aste 1: üks fail)

Üks KOORDINAATOR (loeb, mõõdab, jagab, kontrollib, liidab mandaadiga),
töösessioonid (üks haru, üks failihulk, üks PR). Rahi otsustab ja
kinnitab iga liitmise. Rollid ja töövoog: oskus `koordinaator`. See fail
kannab PROJEKTI fakte, lahtisi asju ja päevikut. Kui siia tekib ≥ 2
paralleelset haru või fail ületab 150 rida, tõsta sisu kolme faili
(README, LAHTISED, POSTKAST — oskuse `assets/koordinatsioon/`).

## Reeglid (lühidalt; täispikalt oskuse README-mallis)

1. Sessioon muudab ainult oma failiomandi faile; võõras fail → „VAJAN:"
   plokk päevikusse.
2. Üks PR = üks asi; tõestus numbritega („see muudatus eeldab X, X on
   mõõdetud Y-ga").
3. Testid fixture'ide vastu, mitte elusate teenuste vastu.
4. Iga kirjutav agent oma worktree; `git add -A` keelatud.
5. Mudeli nime ei kirjutata commitisse ega PR-i.
6. Liitmine ainult Rahi „jah" või mandaadi peale.
7. Sõltuvus = koordinaatori otsus, pinnitud versioon, promptis lubatud.
8. Reposse ainult see, mida projekt vajab; oskused ja isiklikud
   tööriistad elavad kontol.

## Ops-faktid

| Mis | Väärtus |
|---|---|
| Repo, põhiharu | `<omanik>/<repo>`, `main` |
| Deploy | <platvorm, rakendus, auto-deploy — või „ei ole"> |
| Healthcheck / elus versioon | <url — või „ei ole"> |
| Kiired kontrollid | `<npm test / tsc / build …>` |
| Keskkonna lõksud | <muutujad, tööriistad — või „ei ole teada"> |
| Saladused | <kus elavad; MITTE KUNAGI vestlusse> |

## Lahtised

| # | Mis | Kelle käes | Haru / märkus |
|---|---|---|---|
| A1 | | Rahi | |
| B1 | | käimas | |
| C1 | | järjekorras | |

Tehtud rida kriipsuta läbi, ära kustuta enne järgmist koristust.

## Päevik (ainult lisamine, uusim all)

### <kuupäev> — projekti algus (koordinaator)

**Mis on olemas:** <repo seis, mis töötab, mis on toodangus>

**Mis on mõõdetud:** <numbrid ja käsud, millele saab toetuda>

**Mis on lahtine:** <viide ridadele ülal>

**Failiomand:**

| Haru | Omab | Ei puutu |
|---|---|---|
| | | |

Seis: <KÄIMAS / TEHTUD / OOTAB RAHI OTSUST>.
