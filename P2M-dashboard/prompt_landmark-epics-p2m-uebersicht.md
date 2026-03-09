# Ziel
Liste aller Landmark-Release Epics im gewählten Zeitraum, mit Angabe ob sie mindestens einen P2M-Task als Child-Issue haben oder nicht.

# Panel-Typ
Table

# Tabellen
- jira_issues (Epics und P2M-Tasks)
- jira_issue_changelog (für Zeitfilter: letzter Statuswechsel des Epics)

# Zeit-Spalte
Identisch zu sql_landmark-release-mit-p2m-tasks.sql: letzter Statuswechsel des Epics nach 'After Release' (Prio 1) oder 'Done'/'Closed' (Prio 2) aus jira_issue_changelog.

# Ausgabe-Spalten
- issue_key        → "Epic"
- release_date     → "Abschlussdatum"
- hat_p2m_tasks    → "P2M-Tasks vorhanden" (Ja / Nein)

# Aggregation
Keine – eine Zeile pro Epic

# Filter / Bedingungen
Identisch zu sql_landmark-release-mit-p2m-tasks.sql:
- `issue_type = 'Epic'`
- `customfield_10112->>'value' = 'Yes'`
- `customfield_10134->>'value' ILIKE '%Landmark Update%'`
- Zeitfilter auf release_date

# Grafana-Variablen
- `$__timeFilter` auf release_date (äußerste WHERE-Klausel)

# Referenz
Wie sql_landmark-release-mit-p2m-tasks.sql – aber statt %-Aggregation eine Zeile pro Epic mit Ja/Nein-Spalte für P2M-Tasks. Sortierung: release_date DESC.

# Hinweise
- Kein LIMIT nötig – Anzahl der Landmark-Epics ist überschaubar
- Sortierung absteigend nach Abschlussdatum (neueste zuerst)
