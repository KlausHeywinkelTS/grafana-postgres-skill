# Tabelle: jira_issue_changelog

## Beschreibung
Enthält den vollständigen Änderungsverlauf aller Jira-Issues. Jede Zeile repräsentiert eine einzelne Feldänderung an einem Issue (z.B. Statuswechsel, Zuweisung, Prioritätsänderung). Ideal für Verlaufsanalysen und Workflow-Metriken in Grafana.

## Spalten

| Spalte | Typ | Nullable | Beschreibung |
|--------|-----|----------|--------------|
| id | integer | NOT NULL | Primärschlüssel (auto-increment) |
| issue_id | integer | YES | Fremdschlüssel auf `jira_issues.jira_id` |
| issue_key | varchar(50) | NOT NULL | Jira-Schlüssel, z.B. `P2M-123` |
| change_id | integer | NOT NULL | Jira-interne ID des Änderungsvorgangs |
| author_account_id | varchar(100) | YES | Account-ID des Ändernden |
| created_at | timestamptz | YES | Zeitpunkt der Änderung in Jira (**Hauptzeitfeld**) |
| field_name | varchar(100) | YES | Geändertes Feld, z.B. `status`, `assignee`, `priority` |
| field_type | varchar(50) | YES | Feldtyp, z.B. `jira`, `custom` |
| from_value | text | YES | Alter Wert (intern, nicht lesbar) |
| from_display_value | text | YES | Alter Wert (lesbar), z.B. `"Open"` |
| to_value | text | YES | Neuer Wert (intern) |
| to_display_value | text | YES | Neuer Wert (lesbar), z.B. `"In Progress"` |
| issue_created_at | timestamptz | YES | Erstellungszeitpunkt des Issues (denormalisiert) |
| project_key | varchar(50) | YES | Projekt-Kürzel (denormalisiert) |
| issue_type | varchar(100) | YES | Issue-Typ (denormalisiert) |
| priority | varchar(50) | YES | Priorität zum Zeitpunkt der Änderung (denormalisiert) |
| jira_url | varchar(500) | YES | Direktlink zum Issue in Jira |
| story_points | numeric | YES | Story Points zum Zeitpunkt der Änderung (denormalisiert) |
| category | varchar(255) | YES | Kategorie (denormalisiert) |
| is_archived | boolean | YES | Archivierungsstatus (Default: false) |
| archived_at | timestamp | YES | Zeitpunkt der Archivierung |
| created_on | timestamp | YES | Einfügezeitpunkt in die DB |
| last_updated | timestamp | YES | Letztes DB-Update |

## Zeitfelder für Grafana

| Verwendungszweck | Empfohlene Spalte |
|------------------|-------------------|
| `$__timeFilter` für Änderungszeitpunkt | `created_at` (timestamptz) – **Standard** |
| Issue-Erstellungszeitpunkt filtern | `issue_created_at` (timestamptz) |

## Join mit jira_issues

```sql
-- Changelog mit Issue-Details verknüpfen:
FROM jira_issue_changelog c
JOIN jira_issues i ON i.jira_id = c.issue_id
```

## Typische Abfragemuster

```sql
-- Nur Statusänderungen:
WHERE field_name = 'status'

-- Nur Statuswechsel zu "In Progress":
WHERE field_name = 'status' AND to_display_value = 'In Progress'

-- Durchlaufzeit: Wann wurde Issue geöffnet und wann abgeschlossen?
-- (zwei Zeilen pro Issue: from=Open→to=In Progress und from=*→to=Done)

-- Nur aktive Issues (nicht archiviert):
WHERE is_archived = false OR is_archived IS NULL

-- Nur ein Projekt:
WHERE project_key = '${project}'
```

## Wichtige Hinweise

- `from_display_value` / `to_display_value` sind für Statusanalysen zu bevorzugen (lesbare Werte)
- `from_value` / `to_value` enthalten interne Jira-IDs, meist nicht direkt verwendbar
- Denormalisierte Felder (`project_key`, `issue_type`, `priority`, `story_points`) ermöglichen Abfragen ohne JOIN, können aber vom aktuellen Stand in `jira_issues` abweichen
- Für Cycle-Time / Lead-Time Analysen: Timestamps von zwei Changelog-Einträgen desselben Issues vergleichen
