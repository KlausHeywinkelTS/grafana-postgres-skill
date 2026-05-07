# Tabelle: jira_issues

## Beschreibung
Enthält alle Jira-Issues (Tickets) mit ihren Metadaten. Jede Zeile repräsentiert den aktuellen Stand eines Issues.

## Spalten

| Spalte | Typ | Nullable | Beschreibung |
|--------|-----|----------|--------------|
| id | integer | NOT NULL | Primärschlüssel (auto-increment) |
| jira_id | integer | NOT NULL | Interne Jira-ID des Issues |
| issue_key | varchar(50) | NOT NULL | Jira-Schlüssel, z.B. `P2M-123` |
| project_key | varchar(50) | NOT NULL | Projekt-Kürzel, z.B. `P2M` |
| issue_type | varchar(100) | YES | z.B. `Story`, `Bug`, `Task`, `Epic` |
| status | varchar(100) | YES | z.B. `Open`, `In Progress`, `Done` |
| priority | varchar(50) | YES | z.B. `High`, `Medium`, `Low` |
| summary | text | YES | Titel/Betreff des Issues |
| description | text | YES | Beschreibungstext |
| creator_account_id | varchar(100) | YES | Account-ID des Erstellers |
| created_at | timestamptz | YES | Erstellungszeitpunkt in Jira (**Hauptzeitfeld**) |
| updated_at | timestamptz | YES | Letztes Update in Jira |
| due_date | timestamptz | YES | Fälligkeitsdatum |
| resolution_date | timestamptz | YES | Datum der Auflösung/Abschluss |
| story_points | numeric | YES | Geschätzte Story Points |
| original_estimate | integer | YES | Ursprüngliche Zeitschätzung (Sekunden) |
| remaining_estimate | integer | YES | Verbleibende Schätzung (Sekunden) |
| time_spent | integer | YES | Gebuchte Zeit (Sekunden) |
| epic_link | varchar(50) | YES | Issue-Key des zugehörigen Epics |
| parent_key | varchar(50) | YES | Issue-Key des Eltern-Issues – **primäre Beziehung für Child-Issues** (z.B. P2M-Tasks → Epic) |
| labels | text | YES | Kommagetrennte Labels |
| components | text | YES | Kommagetrennte Komponenten |
| fix_versions | text | YES | Kommagetrennte Fix-Versionen |
| custom_fields | jsonb | YES | Sonstige benutzerdefinierte Felder als JSON |
| assignee_account_id | varchar(100) | YES | Account-ID des Bearbeiters |
| reporter_account_id | varchar(100) | YES | Account-ID des Melders |
| category | varchar(255) | YES | Kategorisierung des Issues |
| is_archived | boolean | YES | `true` wenn archiviert (Default: false) |
| archived_at | timestamp | YES | Zeitpunkt der Archivierung |
| created_on | timestamp | YES | Einfügezeitpunkt in die DB (kein Jira-Feld) |
| updated_on | timestamp | YES | Letztes DB-Update (kein Jira-Feld) |
| last_updated | timestamp | YES | Letztes DB-Update (kein Jira-Feld) |

## Zeitfelder für Grafana

| Verwendungszweck | Empfohlene Spalte |
|------------------|-------------------|
| `$__timeFilter` für Issue-Erstellung | `created_at` (timestamptz) |
| `$__timeFilter` für letztes Update | `updated_at` (timestamptz) |
| Abschluss-Zeitverlauf | `resolution_date` (timestamptz) |

> **Hinweis**: `created_on` / `updated_on` / `last_updated` sind DB-interne Felder (ohne Timezone), **nicht** die Jira-Zeitstempel.

## custom_fields (JSONB)

Das Feld `custom_fields` enthält alle Jira-Custom-Fields als JSONB-Objekt.

### Zugriff auf Custom-Field-Werte

```sql
-- Textwert aus einem Custom-Field lesen (->>'value' für den lesbaren Wert):
custom_fields->'customfield_10134'->>'value'

-- In WHERE-Bedingung:
WHERE custom_fields->'customfield_10134'->>'value' = 'Landmark Update (major changes for customers)'

-- Als Ausgabe-Spalte mit Alias:
custom_fields->'customfield_10134'->>'value' AS "Release Type"
```

### JSONB-Operatoren

| Operator | Bedeutung | Beispiel |
|----------|-----------|---------|
| `->` | Gibt JSON-Objekt/Array zurück | `custom_fields->'customfield_10134'` |
| `->>` | Gibt Text zurück | `custom_fields->>'customfield_10134'` |
| `->>'value'` | Wert-Eigenschaft innerhalb eines Feldobjekts | `custom_fields->'customfield_10134'->>'value'` |
| `->>'id'` | ID-Eigenschaft innerhalb eines Feldobjekts | `custom_fields->'customfield_10134'->>'id'` |

### Filter-Beispiele

```sql
-- Exakter Wert:
WHERE custom_fields->'customfield_10134'->>'value' = 'Landmark Update (major changes for customers)'

-- Mehrere Werte (IN):
WHERE custom_fields->'customfield_10134'->>'value' IN ('Landmark Update (major changes for customers)', 'Minor Update')

-- Feld existiert und ist nicht null:
WHERE custom_fields ? 'customfield_10134'
  AND custom_fields->'customfield_10134'->>'value' IS NOT NULL

-- Grafana-Variable auf Custom-Field:
WHERE custom_fields->'customfield_10134'->>'value' = '${release_type}'
```

### Hinweis zur Feldstruktur

Je nach Jira-Konfiguration kann ein Custom-Field ein einfacher Textwert oder ein Objekt mit `value`/`id` sein:

```sql
-- Einfacher Text (kein ->>'value' nötig):
custom_fields->>'customfield_10100'

-- Objekt mit value/id (häufiger bei Select-Listen):
custom_fields->'customfield_10134'->>'value'
```

### Bekannte Custom-Fields

| ID | Jira-Feldname | Zugriff | Mögliche Werte |
|----|---------------|---------|----------------|
| `customfield_10134` | Release Type | `custom_fields->'customfield_10134'->>'value'` | z.B. `'Landmark Update (major changes for customers)'` – **Achtung: Exakt-Match schlägt fehl (versteckte Zeichen im Wert), immer ILIKE verwenden** |
| `customfield_10112` | Relevant for Roadmap | `custom_fields->'customfield_10112'->>'value'` | `'Yes'` oder `'No'` (Großschreibung! Objekt mit value-Property, wie customfield_10134) |
| `customfield_10698` | **Taxonomie / Value Driver / Strategic Pillar** | `custom_fields->'customfield_10698'->>'value'` | Strategische Einordnung eines Issues. Im WISH-Projekt auch „Value Driver" genannt. Werte folgen dem Schema `<Cluster> - <Sub-Pillar>`, z.B. `Reach & Acquisition - Subtext`. Basis-Wert per `btrim(split_part(..., '-', 1))` extrahieren. |

```sql
-- Relevant for Roadmap = yes (Achtung: Großschreibung "Yes"):
WHERE custom_fields->'customfield_10112'->>'value' = 'Yes'

-- Landmark-Release (ILIKE statt = wegen versteckter Zeichen im gespeicherten Wert):
WHERE custom_fields->'customfield_10134'->>'value' ILIKE '%Landmark Update%'
```

## Bekannte Issue-Typen

| issue_type (exakter DB-Wert) | Bedeutung |
|------------------------------|-----------|
| `'Epic'` | Epic = ein Release |
| `'P2M Task'` | P2M-Zulieferung (Child eines Epics) |

## Eltern-Kind-Beziehungen

Child-Issues referenzieren ihren Eltern-Issue über `parent_key` (= `issue_key` des Eltern-Issues).

```sql
-- Alle P2M-Tasks eines Epics:
SELECT child.*
FROM jira_issues child
JOIN jira_issues epic ON epic.issue_key = child.parent_key
WHERE epic.issue_type = 'Epic'
  AND child.issue_type = 'P2M Task'

-- Epics mit mindestens einem P2M-Task (EXISTS):
WHERE EXISTS (
  SELECT 1 FROM jira_issues child
  WHERE child.parent_key = epic.issue_key
    AND child.issue_type = 'P2M Task'
)
```

## Typische Filter

```sql
-- Nur aktive Issues (nicht archiviert):
WHERE is_archived = false OR is_archived IS NULL

-- Nur ein Projekt:
WHERE project_key = '${project}'

-- Nur bestimmte Issue-Typen:
WHERE issue_type IN (${issue_types:raw})

-- Nur offene Issues:
WHERE status NOT IN ('Done', 'Closed', 'Resolved')
```
