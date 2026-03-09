# Ziel
Prozentsatz der Landmark-Releases (Epics mit Release Type = „Landmark Update (major changes for customers)"), die mindestens einen P2M-Task als Child-Issue haben, in Relation zur Gesamtanzahl aller Landmark-Releases im gewählten Zeitraum.

# Panel-Typ
Stat

# Tabellen
- jira_issues (Epics und P2M-Tasks)
- jira_issue_changelog (für Zeitfilter: letzter Statuswechsel des Epics)

# Zeit-Spalte
Kein direktes Zeitfeld in jira_issues – der Zeitfilter basiert auf dem letzten Statuswechsel des Epics aus jira_issue_changelog:
- Priorität 1: letzter Eintrag mit `field_name = 'status'` und `to_value = 'After Release'`
- Priorität 2: letzter Eintrag mit `field_name = 'status'` und `to_value IN ('Done', 'Closed')`

# Ausgabe-Spalten
Einzelner %-Wert:
- (Anzahl Landmark-Epics mit mind. einem P2M-Task / Anzahl aller Landmark-Epics) × 100 → „% Landmark-Releases mit P2M-Tasks"

# Aggregation
COUNT mit Bedingung:
- Zähler A: alle Landmark-Epics im Zeitraum (Gesamt)
- Zähler B: Landmark-Epics, bei denen mindestens ein Child-Issue mit `issue_type = 'P2M Task'` existiert (`parent_key = epic.issue_key`)
- Ergebnis: ROUND(B * 100.0 / NULLIF(A, 0), 1)

# Filter / Bedingungen
- `issue_type = 'Epic'`
- `custom_fields->'customfield_10112'->>'value' = 'Yes'` (Relevant for Roadmap, Großschreibung)
- `custom_fields->'customfield_10134'->>'value' = 'Landmark Update (major changes for customers)'` (Release Type)
- Epics ohne jeglichen Statuswechsel in 'After Release', 'Done' oder 'Closed' werden nicht berücksichtigt

# Grafana-Variablen
- `$__timeFilter` auf das ermittelte letzte Status-Wechsel-Datum des Epics (Subquery aus jira_issue_changelog)
- `${exclude_project_keys}`: Multi-Value-Variable, optional – Projekt-Keys die ausgeschlossen werden sollen. Leer = kein Ausschluss.

# Referenz
–

# Hinweise
- Child-Issues über `parent_key`: `child.parent_key = epic.issue_key`
- P2M-Task: `issue_type = 'P2M Task'` (exakter Wert)
- Landmark-Release ≠ „Relevant for Roadmap" – beide Custom Fields sind unabhängig, beide Filter müssen greifen
- Division durch Null absichern mit NULLIF(A, 0)
