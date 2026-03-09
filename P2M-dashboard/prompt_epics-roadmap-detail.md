# Ziel
Detailliste aller roadmap-relevanten Epics mit Monat, Epic-Key, P2M-Task-Status (ja/nein) und Release-Typ. Eine Zeile pro Epic. Ermöglicht Drill-down auf Einzelebene.

# Panel-Typ
Table

# Tabellen
- jira_issues (Epics und P2M-Tasks)
- jira_issue_changelog (für Zeitfilter: letzter Statuswechsel des Epics)

# Zeit-Spalte
Letzter relevanter Statuswechsel des Epics:
- Prio 1: letzter Wechsel nach 'After Release'
- Prio 2: letzter Wechsel nach 'Done' oder 'Closed'
Ausgabe als formatierter Monatsstring (YYYY-MM).

# Ausgabe-Spalten
- `month`         → "Monat" (Format: YYYY-MM)
- `epic_key`      → "Epic"
- `has_p2m_tasks` → "P2M-Tasks" (yes / no)
- `release_type`  → "Release-Typ" (Wert aus customfield_10134)

# Aggregation
Keine – eine Zeile pro Epic

# Filter / Bedingungen
- `issue_type = 'Epic'`
- `customfield_10112->>'value' = 'Yes'` (Relevant for Roadmap)
- Kein Landmark-Filter – alle Release-Typen werden angezeigt (release_type als Spalte)
- Zeitfilter auf relevant_status_at

# Grafana-Variablen
- `$__timeFilter` auf relevant_status_at (äußerste WHERE-Klausel)
- `${exclude_project_keys}`: Multi-Value, optional – Projekte ausschließen

# Referenz
Wie sql_epics-p2m-verlauf-monatlich.sql – gleiche CTE-Struktur, aber statt monatlicher Aggregation eine Zeile pro Epic mit Detailspalten.

# Hinweise
- Join über `jira_issues.id = jira_issue_changelog.issue_id` (nicht issue_key)
- `release_type` kann NULL sein wenn customfield_10134 nicht gesetzt
- Sortierung: Monat aufsteigend, dann Epic-Key alphabetisch
