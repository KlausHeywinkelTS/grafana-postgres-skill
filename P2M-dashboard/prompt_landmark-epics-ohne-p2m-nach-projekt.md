# Ziel
Verteilung der Landmark-Release Epics OHNE P2M-Tasks auf die verschiedenen Projekte (project_key), als Donut-Diagramm.

# Panel-Typ
Pie Chart (Donut)

# Tabellen
- jira_issues (Epics und P2M-Tasks)
- jira_issue_changelog (für Zeitfilter)

# Zeit-Spalte
Identisch zu sql_landmark-release-mit-p2m-tasks.sql: letzter Statuswechsel des Epics nach 'After Release' (Prio 1) oder 'Done'/'Closed' (Prio 2) aus jira_issue_changelog.

# Ausgabe-Spalten
- project_key  → "Projekt" (Segmentbeschriftung im Donut)
- COUNT(*)     → "Anzahl Epics" (Segmentgröße)

# Aggregation
COUNT pro project_key, nur Epics OHNE P2M-Task-Child

# Filter / Bedingungen
Identisch zu sql_landmark-release-mit-p2m-tasks.sql:
- `issue_type = 'Epic'`
- `customfield_10112->>'value' = 'Yes'`
- `customfield_10134->>'value' ILIKE '%Landmark Update%'`
- Zeitfilter auf release_date
- Zusätzlich: NUR Epics, bei denen KEIN Child-Issue mit `issue_type = 'P2M Task'` existiert (NOT EXISTS)

# Grafana-Variablen
- `$__timeFilter` auf release_date (äußerste WHERE-Klausel)

# Referenz
Wie sql_landmark-epics-p2m-uebersicht.sql – aber nur Epics ohne P2M-Tasks, gruppiert nach project_key mit COUNT.

# Hinweise
- Sortierung: COUNT DESC (größtes Segment zuerst)
- Für Grafana Pie/Donut: erste Spalte = Label, zweite Spalte = Wert
