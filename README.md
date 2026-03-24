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

## Workflow 1: Neues Dashboard erstellen

### 1. Dashboard-Verzeichnis anlegen

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
- **Filter**: project_key = 'WISH'
- **Aggregation**: COUNT pro Status
```

### 3. Prompts bootstrappen

Sage dem Agent:

> „Bootstrappe Prompts für `<dashboard-name>`"

Der Skill liest die Panel-Liste aus dem README und legt für jedes Panel eine vorausgefüllte `prompt_<panel>.md` an. Panels, für die bereits eine Prompt-Datei existiert, werden dabei übersprungen. Fehlende Informationen werden mit `<!-- TODO: ausfüllen -->` markiert.

### 4. Prompts verfeinern

Öffne jede `prompt_<panel>.md` und fülle offene TODOs aus. Soll ein SQL eng an einem bestehenden orientiert sein, trage das unter `## Referenz` ein (siehe [SQL aus Referenz ableiten](#sql-aus-referenz-ableiten)).

### 5. SQL generieren

Sage dem Agent:

> „Generiere SQL für `<dashboard-name>/prompt_<panel>.md`"

Der Skill liest Prompt, Dashboard-README und DB-Schema, fragt fehlende Informationen **alle auf einmal** ab und schreibt `sql_<panel>.sql` in denselben Ordner.

---

## Workflow 2: Panel zu bestehendem Dashboard hinzufügen

### Schritt 1 – Panel im README beschreiben

`README.md` des Dashboards öffnen und einen neuen Panel-Abschnitt ergänzen (Format wie im Beispiel unter Workflow 1, Schritt 2). Das README ist die einzige Pflegestelle für die Panel-Übersicht des Dashboards.

### Schritt 2 – Prompt-Grundgerüst generieren

Sage dem Agent:

> „Bootstrappe Prompts für `<dashboard-name>`"

Der Skill legt **nur für Panels ohne vorhandene `prompt_*.md`** eine neue Datei an – bestehende werden nicht angefasst. Vor dem Anlegen zeigt er eine Vorschau und wartet auf Bestätigung.

### Schritt 3 – Prompt verfeinern (optional)

Die neue `prompt_<panel>.md` öffnen und etwaige `<!-- TODO: ausfüllen -->`-Marker ergänzen, z. B. genaue Spaltennamen, Filterwerte oder eine Referenz auf ein bestehendes SQL (siehe [SQL aus Referenz ableiten](#sql-aus-referenz-ableiten)).

### Schritt 4 – SQL generieren

Sage dem Agent:

> „Generiere SQL für `<dashboard-name>/prompt_<panel>.md`"

**Kurzform:**

```
README ergänzen  →  „Bootstrappe Prompts"  →  prompt_*.md prüfen  →  „Generiere SQL"  →  sql_*.sql
```

> **Abkürzung:** Wer Schritt 1 + 2 überspringen möchte, kann direkt sagen:
> „Lege eine neue Prompt-Datei für Panel X im Verzeichnis `<ordner>` an" –
> der Skill erstellt die Datei dann aus einem Template ohne vorheriges Bootstrapping.

---

## Einzeloperationen

### SQL aus Referenz ableiten

Soll ein neues SQL eng an einem bestehenden orientiert sein, genügt folgender Eintrag in der `prompt_*.md` unter `## Referenz`:

> „Wie `sql_xyz.sql` – aber mit folgenden Änderungen: ..."

Der Skill liest die referenzierte Datei, wendet die beschriebenen Änderungen an und dokumentiert sie im Header-Kommentarblock des neuen SQL.

### README in bestehendem Ordner anlegen

Falls ein Dashboard-Ordner bereits existiert, aber noch kein README hat:

> „Lege mir ein README im Verzeichnis `<ordner>` an"

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
