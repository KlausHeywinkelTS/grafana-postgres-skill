# Ziel
Monatlicher Verlauf aller roadmap-relevanten Epics, aufgeteilt in zwei Metriken: Epics MIT mindestens einem P2M-Task und Epics OHNE P2M-Tasks. Zeigt die Entwicklung der P2M-Abdeckung über die Zeit.

# Panel-Typ
Bar chart

# Tabellen
- jira_issues (Epics und P2M-Tasks)
- jira_issue_changelog (für Zeitfilter: letzter Statuswechsel des Epics)

# Zeit-Spalte
Letzter relevanter Statuswechsel des Epics (wie in anderen Panels):
- Prio 1: letzter Wechsel nach 'After Release'
- Prio 2: letzter Wechsel nach 'Done' oder 'Closed'
Datum wird per `date_trunc('month', ...)` auf Monatsebene aggregiert.

# Ausgabe-Spalten
- `month` → Monat (AS time für Grafana Time Series)
- `epic_count_without_p2m` → "Epics ohne P2M-Tasks"
- `epic_count_with_p2m`    → "Epics mit P2M-Tasks"

# Aggregation
COUNT pro Monat, mit zwei bedingten Zählern (FILTER WHERE):
- Ohne P2M: kein Eintrag in p2m_parents für dieses Epic
- Mit P2M: mindestens ein Eintrag in p2m_parents

# Filter / Bedingungen
- `issue_type = 'Epic'`
- `customfield_10112->>'value' = 'Yes'` (Relevant for Roadmap)
- **Kein** Landmark-Filter (customfield_10134) – alle roadmap-relevanten Epics
- Zeitfilter auf relevant_status_at

# Grafana-Variablen
- `$__timeFilter` auf relevant_status_at (äußerste WHERE-Klausel)
- `${exclude_project_keys}`: Multi-Value, optional – Projekte ausschließen

# Referenz
–

# Hinweise
- Join-Strategie: Changelog wird über `jira_issues.id = jira_issue_changelog.issue_id` verknüpft (nicht über issue_key)
- P2M-Eltern werden über `child.parent_key` ermittelt (CTE p2m_parents)
- Kein Landmark-Filter → mehr Epics als in den anderen Panels
- Sortierung: monatlich aufsteigend (Grafana Time Series erwartet ASC)
