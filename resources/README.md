# Tabellendefinitionen

Dieses Verzeichnis enthält die PostgreSQL-Tabellendefinitionen, die vom Skill `grafana-sql-generator` zur Validierung und Generierung von SQL-Statements verwendet werden.

## Konvention

Lege pro Tabelle eine Datei an:

```
resources/
├── table_<tabellenname>.md    # Tabellenbeschreibung im Markdown-Format (empfohlen)
└── table_<tabellenname>.sql   # Alternativ: CREATE TABLE Statement
```

## Empfohlenes Format für .md Dateien

```markdown
# Tabelle: <tabellenname>

## Beschreibung
<Wofür wird die Tabelle verwendet?>

## Spalten

| Spalte | Typ | Nullable | Beschreibung |
|--------|-----|----------|--------------|
| id | BIGSERIAL | NOT NULL | Primärschlüssel |
| timestamp_col | TIMESTAMPTZ | NOT NULL | Zeitstempel (für $__timeFilter verwenden) |
| device_id | VARCHAR(100) | NOT NULL | Geräte-ID |
| value | DOUBLE PRECISION | NULL | Messwert |
| created_at | TIMESTAMPTZ | NOT NULL | Erstellungszeitpunkt |

## Indizes
- PRIMARY KEY: id
- INDEX auf: timestamp_col (für Grafana-Zeitfilter-Performance)

## Hinweise
- <Besonderheiten, Timezone-Handling, Partitionierung, etc.>
```

## Vorhandene Tabellen

| Datei | Tabelle | Beschreibung |
|-------|---------|--------------|
| [table_jira_issues.md](table_jira_issues.md) | `jira_issues` | Aktueller Stand aller Jira-Issues |
| [table_jira_issue_changelog.md](table_jira_issue_changelog.md) | `jira_issue_changelog` | Vollständiger Änderungsverlauf aller Issues |

> Die CSV-Originaldateien (`Columns_*.csv`) aus dem Datenbankexport bleiben als Referenz erhalten.
