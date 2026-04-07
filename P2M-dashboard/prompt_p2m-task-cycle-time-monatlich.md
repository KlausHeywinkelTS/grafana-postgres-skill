# Ziel
Durchschnittliche Cycle Time bereits abgeschlossener P2M-Tasks pro Abschlussmonat. Jeder P2M-Task soll genau dem Monat zugeordnet werden, in dem er final auf `Done` oder `Rejected` gesetzt wurde. Das Ergebnis soll als Bar-Chart angezeigt werden: x-Achse = Monat, y-Achse = durchschnittliche Cycle Time aller in diesem Monat geschlossenen P2M-Tasks.

# Panel-Typ
Bar chart

# Tabellen
- jira_issues (P2M-Tasks, Erstellungszeitpunkt)
- jira_issue_changelog (Statuswechsel für Abschlussdatum)

# Zeit-Spalte
Abschlussdatum des P2M-Tasks aus `jira_issue_changelog.created_at`, und zwar der letzte/finale Statuswechsel mit:
- `field_name = 'status'`
- `to_value IN ('Done', 'Rejected')`

Dieses Datum wird per `date_trunc('month', closed_at)` auf Monatsebene gruppiert.

# Ausgabe-Spalten
- `month` -> Monatslabel für die x-Achse, z.B. `YYYY-MM`
- `avg_cycle_time_days` -> "Durchschnittliche Cycle Time (Tage)"

# Aggregation
AVG der Cycle Time pro Monat.

Definition der Cycle Time pro Task:
- `closed_at - jira_issues.created_at`
- Ausgabe als Anzahl Tage, idealerweise numerisch/decimal (z.B. auf 1 Nachkommastelle gerundet)

Jeder Task soll nur einmal gezählt werden, basierend auf seinem finalen Abschlussdatum.

# Filter / Bedingungen
- `jira_issues.issue_type = 'P2M Task'`
- Nur Tasks berücksichtigen, für die ein finaler Statuswechsel nach `Done` oder `Rejected` existiert
- Aufgaben ohne Abschlussdatum nicht berücksichtigen
- Zeitfilter auf `closed_at`

# Grafana-Variablen
- `$__timeFilter` auf `closed_at` (äußerste WHERE-Klausel)
- `${exclude_project_keys}`: Multi-Value, optional – Projekte ausschließen

# Referenz
–

# Hinweise
- Join Changelog zu Issues über `jira_issues.issue_key = jira_issue_changelog.issue_key`
- Für Statusanalysen in diesem Projekt `to_value` verwenden
- Falls ein Task mehrfach nach `Done` oder `Rejected` gewechselt ist, den letzten/finalen Wechsel verwenden
- Für ein Bar-Chart ist kein `AS time` nötig; die Monatsachse soll als Kategorie dargestellt werden, nicht als Time Series
- Sortierung: Monat aufsteigend
