# Mida iga PR peab tõestama

Sõna „töötab" ei ole tõestus. Tõestus on number, mille keegi teine saab
sama käsuga uuesti saada.

## Miinimum, mis kehtib igas projektis

1. Projekti kiired kontrollid rohelised (test, lint, typecheck, build —
   need, mis projektil on; kui ühtegi ei ole, on esimene töö see luua).
2. Üks mõõtmine ENNE ja PÄRAST, mille keegi teine saab sama käsuga
   korrata (väljund, aeg, arv, kuvatõmmis) — ja käsk on PR-is kirjas.
3. Lause „see muudatus eeldab X, X on mõõdetud Y-ga".
4. Mida tõestus EI kata, öeldud välja (andmete ulatus, emulatsioon vs
   päris seade, mõõtmata mõõdikud). Aus „ei mõõtnud" on parem kui
   vaikimisi „korras".

## Täpsustus PR-tüübi ja projektitüübi kaupa

| PR tüüp | Lisaks miinimumile |
|---|---|
| Refaktor / tükeldamine | käitumise samasus: UI-l pikslivõrdlus enne/pärast mitmes seisus (siht 0), müra põrand mõõdetud SAMA koodi kahe käiguga; skriptil/teenusel sama sisend → baidiliselt sama väljund; jõudlusmõõdik ei halvene (mitu käiku, vahemikud kattuvad); avalik liides muutumata |
| Stiili/seadistuse ümberkorraldus | ehitatud väljund baidiliselt sama (md5) — katab kõik seisud korraga |
| Veaparandus | reprodutseeriv proov ENNE (number, mis on vale) ja PÄRAST (õige), samades tingimustes; test, mis enne kukub |
| Funktsioon | mida lisab (read, failid); käitumistest; UI-l kuvatõmmised igal sihtseadmel eraldi |
| Tekst / docs | kiired kontrollid; grep, et vana tekst on kadunud |
| Ops / deploy | API või käsu vastus enne/pärast, healthcheck, elus versioon |

| Projektitüüp | Mis on „mõõtmine" |
|---|---|
| Veebirakendus UI-ga | Playwright-proov fikseeritud seisus, kuvatõmmis, pikslite arv, DOM-i kastid, `queryRenderedFeatures`-laadsed loendused |
| Käsurea skript | sama sisend → väljund diff, käivitusaeg, exit code |
| API / teenus | päring → vastus (staatus, keha, aeg), enne/pärast |
| Andmetöötlus | rea-/objektiarv sisse ja välja, kontrollsumma, näidisrida |

## Mõõtmise enda lõksud

- Üks käik ei tõesta: mõõda sama koodi kaks korda, et teada, mis on müra.
- Taimer ei ole sünkroon: oota süsteemi enda „valmis" signaali.
- Tuletatud hulk (failid, testid, objektid), mis jääb tühjaks, peab
  kukkuma valjult — muidu mõõdab test mitte midagi ja läbib.
- Agendi raport ei ole tõend; jooksuta käsk ise.
- Elusate teenuste vastu ei testita; lugevad päringud võrdluseks on
  lubatud, kui projekt seda ei keela.
