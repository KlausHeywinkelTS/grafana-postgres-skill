# Prompt: Distribution of Bug Priority

## Ziel

Zeigt die Verteilung der offenen Bug-Issues nach Prioritätsgruppe. Offen bedeutet: Status ist nicht in der Done-Kategorie (`Done`, `Closed`, `Rejected`). Der Grafana-Zeitfilter bezieht sich auf das Erstellungsdatum.

## Panel-Typ

Bar Chart

## Tabellen

jira_issues

## Zeit-Spalte

jira_issues.created_at

## Ausgabe-Spalten

Prioritätsgruppe → "Priorität"
COUNT(*) → "Anzahl Bugs"

## Aggregation

COUNT aller passenden offenen Bug-Issues pro Prioritätsgruppe

## Filter / Bedingungen

- `issue_type = 'Bug'`
- Statuskategorie ist nicht `Done`; als `Done` gelten die Statuswerte `Done`, `Closed` und `Rejected`
- Projekt-Filter über `${project}`; bei Auswahl von `All` alle Product-Team-Projekte berücksichtigen: `INV`, `QUE`, `REVIN`, `RM`, `CC`, `LSRT`, `PL`, `TBI`, `TPSCON`, `GUARANTEE`, `SEO`, `CA`, `TCM`
- Grafana-Zeitfilter auf `jira_issues.created_at`

## Grafana-Variablen

${project}, $__timeFilter

## Referenz

–

## Hinweise

- Prioritätswerte zu Gruppen zusammenfassen:
  - `Showstopper` ← `Show stopper`, `Showstopper`
  - `High` ← `High`, `Major`, `High Standard`
  - `Medium` ← `Medium`, `Normal`
  - `Low` ← `Low`, `Trivial`, `Minor`
  - `None` ← `None`, leere/fehlende Priorität
- Vor dem Match Prioritätsstrings normalisieren (`btrim`, Non-Breaking Spaces entfernen, Whitespace kollabieren) und per `ILIKE` vergleichen, damit versteckte Zeichen keine Doppel-Gruppen erzeugen.
- Andere Prioritätswerte unverändert als eigene Gruppe belassen.
- Balken von links nach rechts: Showstopper → High → Medium → Low → None → übrige.
- Kein `is_archived` verwenden.
- Die Auswahl `All` muss alle genannten Product-Team-Projekte einschließen, nicht Projekte außerhalb dieser Liste.
