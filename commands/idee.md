---
description: Salvesta praegune mõte/idee/otsus PM-i märkmena (weight 3)
---

Salvesta see, mida me just arutasime, PM-i märkmena tööriistaga `pm_capture_note`.

Kui kasutaja lisas käsule teksti, on see märkme fookus: $ARGUMENTS

Reeglid:
- Vali `kind` sisu järgi: `idea` (pakutud, veel tegemata), `decision` (tehtud valik koos põhjendusega ja kõrvale jäetud alternatiiviga), `implementation` (päriselt ehitatud asi ja kuidas), `lesson` (mis läks valesti või üllatas), `story` (konkreetne jutustatav episood).
- `weight: 3` alati — seda märkis inimene.
- `body` kirjuta nii, et see on arusaadav kuude pärast ilma ümbritseva vestluseta. Too sisse konkreetsed nimed, numbrid ja põhjendused. Ära kirjuta "nagu eespool arutatud".
- `tags`: 3-6 tükki. Valdkonnaterminid eesti keeles, tehnilised inglise keeles.
- Kui jutt käis konkreetsest projektist, lisa `projectCode`. Kui sa ei ole kindel, jäta lisamata — vale seos on halvem kui puuduv.
- Ära muuda `source` väärtust: see peab jääma `manual`.

Pärast salvestamist ütle ühe lausega, mis salvestati ja mis id sai. Kui vastuses on `unresolved`, ütle see ka.
