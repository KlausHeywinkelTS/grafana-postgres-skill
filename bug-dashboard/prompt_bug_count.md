# Prompt: Bug-Count

## Ziel

Zeigt die Anzahl der offenen Bug-Issues in den Product-Team-Projekten, die dem gewählten Projekt- und Zeitfilter entsprechen. Offen bedeutet: Status ist nicht in der Done-Kategorie (`Done`, `Closed`, `Rejected`). Der Zeitfilter bezieht sich auf das Erstellungsdatum des Bugs.

## Panel-Typ

Stat

## Tabellen

jira_issues

## Zeit-Spalte

jira_issues.created_at

## Ausgabe-Spalten

COUNT(*) → "Anzahl Bugs"

## Aggregation

COUNT aller passenden offenen Bug-Issues

## Filter / Bedingungen

- `issue_type = 'Bug'`
- Statuskategorie ist nicht `Done`; als `Done` gelten die Statuswerte `Done`, `Closed` und `Rejected`
- Projekt-Filter als `project_key IN (${project:sqlstring})`; bei Auswahl von `All` alle Product-Team-Projekte berücksichtigen: `INV`, `QUE`, `REVIN`, `RM`, `CC`, `LSRT`, `PL`, `TBI`, `TPSCON`, `GUARANTEE`, `SEO`, `CA`, `TCM`
- Grafana-Zeitfilter auf `jira_issues.created_at`

## Grafana-Variablen

${project:sqlstring}, $__timeFilter

## Referenz

–

## Hinweise

- Kein `is_archived` verwenden.
- Die Auswahl `All` muss alle genannten Product-Team-Projekte einschließen, nicht Projekte außerhalb dieser Liste.
