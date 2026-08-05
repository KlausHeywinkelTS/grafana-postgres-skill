# Prompt: Age of Bugs

## Ziel

Zeigt die Anzahl der Bug-Issues, die nicht zur Statuskategorie `Done` gehören, je Altersgruppe. Die Statuskategorie `Done` umfasst die Status `Done`, `Closed` und `Rejected`. Das Alter eines Bugs ist die Dauer zwischen `created_at` und dem aktuellen Zeitpunkt. Der Grafana-Zeitfilter bezieht sich auf das Erstellungsdatum des Bugs.

## Panel-Typ

Bar Chart

## Tabellen

jira_issues

## Zeit-Spalte

jira_issues.created_at

## Ausgabe-Spalten

Altersgruppe → "Altersgruppe"
COUNT(*) → "Anzahl Bugs"

## Aggregation

COUNT aller passenden Bug-Issues pro Altersgruppe

## Filter / Bedingungen

- `issue_type = 'Bug'`
- Statuskategorie ist nicht `Done`; als `Done` gelten die Statuswerte `Done`, `Closed` und `Rejected`
- Projekt-Filter über `${project}`; bei Auswahl von `All` alle Product-Team-Projekte berücksichtigen: `INV`, `QUE`, `REVIN`, `RM`, `CC`, `LSRT`, `PL`, `TBI`, `TPSCON`, `GUARANTEE`, `SEO`, `CA`, `TCM`
- Grafana-Zeitfilter auf `jira_issues.created_at`
- Altersgruppen: `<= 30 Tage`, `> 30 und <= 60 Tage`, `> 60 und <= 90 Tage`, `> 90 und <= 365 Tage`, `> 365 und < 730 Tage`, `>= 730 Tage`

## Grafana-Variablen

${project}, $__timeFilter

## Referenz

–

## Hinweise

- Die Balken in aufsteigender Reihenfolge der Altersgruppen ausgeben.
- Kein `is_archived` verwenden.
- Die Auswahl `All` muss alle genannten Product-Team-Projekte einschließen, nicht Projekte außerhalb dieser Liste.
- `$__timeFilter` nicht in CTEs verwenden; `created_at` durchreichen und im äußeren JOIN filtern.
