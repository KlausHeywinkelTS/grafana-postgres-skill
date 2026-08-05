# Prompt: Distribution of Bugs per Team

## Ziel

Zeigt die Verteilung der offenen Bug-Issues nach Team. Team bedeutet: Key des Jira-Projekts (`project_key`). Offen bedeutet: Status ist nicht in der Done-Kategorie (`Done`, `Closed`, `Rejected`). Der Grafana-Zeitfilter bezieht sich auf das Erstellungsdatum.

## Panel-Typ

Bar Chart

## Tabellen

jira_issues

## Zeit-Spalte

jira_issues.created_at

## Ausgabe-Spalten

project_key → "Team"
COUNT(*) → "Anzahl Bugs"

## Aggregation

COUNT aller passenden offenen Bug-Issues pro Team (`project_key`)

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

- Team = `jira_issues.project_key`.
- Balken alphabetisch nach Team (`project_key`) sortieren.
- Kein `is_archived` verwenden.
- Die Auswahl `All` muss alle genannten Product-Team-Projekte einschließen, nicht Projekte außerhalb dieser Liste.
- `$__timeFilter` nicht in CTEs verwenden; `created_at` durchreichen und im äußersten WHERE filtern.
