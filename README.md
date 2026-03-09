# Grafana PostgreSQL SQL Generator

Dieses Projekt enthält einen Cursor-Skill, der dabei hilft, PostgreSQL-SQL-Statements für Grafana-Dashboards zu generieren – optimiert für die Arbeit mit Jira-Daten.

## Voraussetzungen

- [Cursor IDE](https://www.cursor.com/) mit aktivierten Agent Skills

## Projektstruktur

```
grafana-postgres-skills/
├── resources/                              ← Tabellendefinitionen der Postgres-DB
│   ├── table_jira_issues.md               ← Schema: jira_issues
│   └── table_jira_issue_changelog.md      ← Schema: jira_issue_changelog
├── <dashboard-name>/                       ← Ein Ordner pro Grafana-Dashboard
│   ├── README.md                           ← Dashboard-Beschreibung + Panel-Liste
│   ├── prompt_<panel>.md                  ← Beschreibung eines einzelnen Panels
│   └── sql_<panel>.sql                    ← Generiertes SQL für Grafana
└── .cursor/skills/grafana-sql-generator/  ← Cursor-Skill (automatisch aktiv)
```

---

## Schnellstart

### 1. Neues Dashboard anlegen

Sage dem Cursor-Agent:

> „Lege ein neues Dashboard-Verzeichnis an"

Der Skill fragt nach dem Namen und erstellt den Ordner mit einer vorausgefüllten `README.md`.

### 2. Dashboard beschreiben

Öffne die erzeugte `README.md` im Dashboard-Ordner und beschreibe:
- **Zweck** des Dashboards
- **Dashboard-Variablen** (Grafana-Filter, die in SQLs verwendet werden sollen)
- **Panel-Liste** – pro Panel: Name, Typ, was es zeigen soll

Beispiel für einen Panel-Eintrag:

```markdown
### Panel: Offene Issues pro Status
- **Typ**: Bar Chart
- **Beschreibung**: Zeigt die Anzahl offener Issues gruppiert nach Status
- **Metriken / Spalten**: status, COUNT(*) als Anzahl
- **Filter**: Nur is_archived = false
- **Aggregation**: COUNT pro Status
```

### 3. Prompt-Grundgerüste generieren (Bootstrapping)

Sage dem Agent:

> „Bootstrappe Prompts für `<dashboard-name>`"

Der Skill liest die Panel-Liste aus dem README und legt für jedes Panel eine vorausgefüllte `prompt_<panel>.md` an. Fehlende Informationen werden mit `<!-- TODO: ausfüllen -->` markiert.

### 4. Prompt verfeinern

Öffne die gewünschte `prompt_<panel>.md` und fülle offene TODOs aus. Optional kannst du auf ein bestehendes SQL verweisen:

```markdown
# Referenz
Wie sql_offene-issues.sql – aber nur für Issues mit story_points > 0
```

### 5. SQL generieren

Sage dem Agent:

> „Generiere SQL für `<dashboard-name>/prompt_<panel>.md`"

Der Skill prüft das Schema, fragt fehlende Informationen ab und schreibt `sql_<panel>.sql` in denselben Ordner.

---

## Arbeiten mit bestehenden Dashboards

### README in bestehendem Ordner anlegen

> „Lege mir ein README im Verzeichnis `<ordner>` an"

### Einzelne Prompt-Datei anlegen

> „Lege eine neue Prompt-Datei für Panel X im Verzeichnis `<ordner>` an"

### SQL aus Referenz ableiten

In der `prompt_*.md` unter `# Referenz`:

> „Wie `sql_xyz.sql` – aber mit folgenden Änderungen: ..."

Der Skill übernimmt das bestehende SQL und wendet die Änderungen an.

---

## Tabellenschema erweitern

Neue Custom-Fields oder Erkenntnisse zum Schema in `resources/table_jira_issues.md` bzw. `resources/table_jira_issue_changelog.md` ergänzen. Der Skill liest diese Dateien automatisch bei jeder SQL-Generierung.

---

## Grafana-Besonderheiten

Der Skill kennt alle relevanten Grafana-Macros und wendet sie automatisch an:

| Macro | Verwendung |
|-------|-----------|
| `$__timeFilter(col)` | Zeitfenster-Filter (immer verwenden) |
| `$__timeGroupAlias(col, $__interval)` | Zeitbuckets für Time-Series-Panels |
| `${variable}` | Dashboard-Variablen |
| `${variable:raw}` | Multi-Value-Variablen für `IN`-Klauseln |

Für die vollständige Macro-Referenz siehe `.cursor/skills/grafana-sql-generator/grafana-macros.md`.
