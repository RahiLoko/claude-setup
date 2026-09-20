# Otsuseleht (režiim A: idee või dokument)

Rahi annab idee, dokumendi või lingi. Ära hakka ehitama; kirjuta
otsuseleht ja too see VESTLUSSE lühidalt (mitte faili — faili teed alles
otsuse järel LAHTISED-i ridadena). Eesmärk on, et Rahi saaks otsustada
ühe sõnumi pealt.

```
IDEE ÜHE LAUSEGA: <mis see on, kellele, mida annab>

MIS ON JUBA OLEMAS: <mida kood/docs täna teevad, mis katab osa ideest;
  mõõdetud, mitte oletatud — vaata koodist, git logist, LAHTISED-ist>

MIS MAKSAB:
  | Variant | Mida teeb | Sessioone | Risk | Mida EI tee |
  | A minimaalne | … | 1 | … | … |
  | B täis | … | 3 | … | … |
  | C ei tee | — | 0 | mis jääb tegemata | … |

SOOVITUS: <üks variant, üks lause miks>

KÜSIMUSED, MIS VASTUST VAJAVAD (kuni 3): <ainult need, mille vastus
  muudab tööd; a/b kujul, kui võimalik>

TEHNILINE VALIK (ainult tühjal projektil): <keel, raamistik, kus jookseb,
  deploy; üks lause miks; mida see välistab>

ESIMENE PR (ainult tühjal projektil): <skelett + kiire kontroll + üks
  läbiv tükk ideest>

EELDUSED, MIDA MÕÕTA ENNE: <nt „teenus X annab välja Y", „telefon kannab
  Z" — ja kuidas seda mõõdad>
```

Pärast Rahi otsust:

1. LAHTISED-i read (C-tabel: mis, kust, märkus), üks rida = üks PR.
2. POSTKAST-i plokk: otsus, kuupäev, Rahi sõnad tsitaadina, failiomand.
3. Sessioonid `sessiooni-mall.md` järgi; mõõtmised, mis on „enne"
   vaja, tee ise või anna esimese sessiooni esimeseks commitiks.

Kui dokument on pikk (ideedokument, lähteülesanne), loe ta tervenisti,
aga vestlusse too ainult otsuseleht. Rahi ütles: „ära too sisu, mis
saab lugeda failidest".
