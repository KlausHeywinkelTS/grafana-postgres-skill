# Prompt: Bug Lead Time

## Ziel

Zeigt die durchschnittliche Lead Time geschlossener Bug-Issues: die Dauer von der Erstellung bis zur Auflösung. Der Grafana-Zeitfilter bezieht sich auf das Auflösungsdatum, damit nur im Zeitraum geschlossene Bugs einfließen.

## Panel-Typ

Stat

## Tabellen

jira_issues

## Zeit-Spalte

jira_issues.resolution_date

## Ausgabe-Spalten

AVG(resolution_date - created_at) → "Durchschnittliche Bug Lead Time"

## Aggregation

AVG der Dauer zwischen `created_at` und `resolution_date` für alle passenden Bug-Issues

## Filter / Bedingungen

- `issue_type = 'Bug'`
- status in 'Done', 'Closed'
- `resolution_date IS NOT NULL`
- Projekt-Filter über `${project}`; bei Auswahl von `All` alle Product-Team-Projekte berücksichtigen: `INV`, `QUE`, `REVIN`, `RM`, `CC`, `LSRT`, `PL`, `TBI`, `TPSCON`, `GUARANTEE`, `SEO`, `CA`, `TCM`
- Grafana-Zeitfilter auf `jira_issues.resolution_date`

## Grafana-Variablen

${project}, $__timeFilter

## Referenz

–

## Hinweise

- Die Lead Time als für Grafana gut lesbare Dauer ausgeben; die konkrete Einheit bei der SQL-Generierung festlegen.
- Kein `is_archived` verwenden.
- Die Auswahl `All` muss alle genannten Product-Team-Projekte einschließen, nicht Projekte außerhalb dieser Liste.
