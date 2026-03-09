---
name: grafana-sql-generator
description: Generates PostgreSQL SQL statements optimized for Grafana dashboards from prompt_*.md files. Use when a prompt_*.md file exists or is mentioned, when the user wants to generate SQL for a Grafana panel, when creating sql_*.sql files, when a dashboard folder or its README.md is referenced, when bootstrapping prompt files from a dashboard README, or when the user asks to create a new dashboard directory/folder. Handles Grafana macros, cross-references between SQL files, validates column names against schema definitions in resources/, auto-generates prompt skeletons from dashboard README panel lists, and creates new dashboard folders with README templates.
---

# Grafana SQL Generator

## Ordnerstruktur

Prompts und SQLs leben ausschließlich in **Dashboard-Unterordnern**:

```
<dashboard-name>/
├── README.md              ← Dashboard-Beschreibung + Panel-Liste (Pflicht)
├── prompt_<panel>.md      ← Ein Prompt pro Panel
└── sql_<panel>.sql        ← Generiertes SQL pro Panel
```

## Workflow A – SQL aus Prompt generieren

1. **Prompt-Datei lesen** – `prompt_<goal>.md` im Dashboard-Ordner
2. **Dashboard-README lesen** – `README.md` im selben Ordner (Kontext für Variablen, Ziel)
3. **Tabellenschema lesen** – alle Dateien in `resources/`
4. **Cross-References auflösen** – referenzierte SQL-Dateien lesen
5. **Fehlende Infos abfragen** – alle offenen Punkte **auf einmal** erfragen (nicht iterativ)
6. **SQL generieren** – `sql_<goal>.sql` im selben Ordner erstellen
7. **Validieren** – Spaltennamen gegen Schema prüfen

## Workflow B – Prompt-Grundgerüste aus Dashboard-README bootstrappen

Auslöser: User verweist auf einen Dashboard-Ordner oder dessen README, und es existieren noch keine / zu wenige Prompt-Dateien.

1. **README lesen** – Dashboard-`README.md` einlesen
2. **Panel-Liste extrahieren** – alle definierten Panels mit Typ, Beschreibung, Variablen
3. **Tabellenschema lesen** – alle Dateien in `resources/`
4. **Bestehende Prompts prüfen** – bereits vorhandene `prompt_*.md` Dateien im Ordner identifizieren
5. **Vorschau zeigen** – dem User auflisten, welche Prompt-Dateien angelegt werden sollen (nur fehlende)
6. **Bestätigung einholen** – vor dem Anlegen explizit bestätigen lassen
7. **Prompt-Grundgerüste erstellen** – pro Panel eine `prompt_<panel-name>.md` mit vorausgefüllten Feldern anlegen

### Vorausfüllung der Prompt-Grundgerüste

Aus dem README-Panel-Eintrag so viel wie möglich vorausfüllen:

| README-Feld | → Prompt-Feld |
|-------------|---------------|
| Panel-Name | Dateiname + Ziel |
| Panel-Typ | Panel-Typ |
| Beschreibung | Ziel (ausformuliert) |
| Dashboard-Variablen | Grafana-Variablen |
| Erwähnte Felder/Metriken | Ausgabe-Spalten (Vorschlag) |
| Tabellen-Hinweise | Tabellen |

Felder, die nicht aus dem README ableitbar sind, mit `<!-- TODO: ausfüllen -->` markieren.

## Fehlende Informationen abfragen

Vor der Generierung prüfen, ob folgende Punkte aus dem Prompt hervorgehen. Fehlende Punkte **alle auf einmal** abfragen (kein iteratives Nachfragen):

- **Panel-Typ**: Time Series / Table / Stat / Gauge / Bar Chart?
- **Tabellen**: Welche Tabellen werden benötigt?
- **Zeit-Spalte**: Welche Spalte enthält den Timestamp? (bei Time Series Panels)
- **Aggregation**: Rohdaten oder aggregiert (z.B. AVG/COUNT pro `$__interval`)?
- **Ausgabe-Spalten**: Welche Werte sollen angezeigt werden, mit welchen Aliases (wichtig für Grafana-Legende)?
- **Filter**: Zusätzliche WHERE-Bedingungen außer dem Zeitfilter?
- **Grafana-Variablen**: Dashboard-Variablen wie `${device}`, `${location}` etc.?
- **Erwartete Datenmenge**: Für LIMIT-Entscheidung bei Table-Panels

## Cross-References

Der Prompt kann eine andere SQL-Datei referenzieren:

> "Ein SQL wie in `sql_xyz.sql` – aber mit folgenden Änderungen: ..."

Vorgehen:
1. Referenzierte SQL-Datei lesen
2. Beschriebene Änderungen anwenden
3. Änderungen im Header-Kommentarblock der neuen SQL-Datei dokumentieren

## Panel-spezifische SQL-Regeln

### Time Series
Zwingend erforderlich:
- Timestamp-Spalte mit Alias `AS time`
- Metriken als benannte Spalten (Alias = Grafana-Legendenname)
- `$__timeFilter(time_column)` in der WHERE-Klausel
- `ORDER BY time ASC`

```sql
SELECT
  timestamp_col AS time,
  avg_value     AS "Durchschnitt Temperatur"
FROM my_table
WHERE $__timeFilter(timestamp_col)
ORDER BY time ASC
```

### Time Series aggregiert (empfohlen für große Datenmengen)
```sql
SELECT
  $__timeGroupAlias(timestamp_col, $__interval),
  AVG(value) AS "Durchschnitt"
FROM my_table
WHERE $__timeFilter(timestamp_col)
GROUP BY 1
ORDER BY 1 ASC
```

### Stat / Gauge (Einzelwert)
```sql
SELECT COUNT(*) AS "Anzahl gesamt"
FROM my_table
WHERE $__timeFilter(timestamp_col)
```

### Table (freies Format)
- Kein Pflicht-Alias, aber sinnvolle deutsche/sprechende Spaltennamen
- Immer `LIMIT` setzen (Sicherheitsnetz)

## Output-Format

Datei: `sql_<goal>.sql` im selben Verzeichnis wie die Prompt-Datei.

Header-Kommentarblock immer einfügen:

```sql
-- ============================================================
-- Ziel:        <Beschreibung aus Prompt>
-- Panel-Typ:   <Typ>
-- Tabellen:    <Tabellennamen>
-- Variablen:   <Grafana-Variablen oder "keine">
-- Basis-SQL:   <Referenzierte Datei oder "–">
-- Erstellt:    <Datum>
-- ============================================================

SELECT ...
```

## Validierungs-Checkliste

Nach der Generierung prüfen:
- [ ] Alle verwendeten Spaltennamen existieren im Schema (`resources/`)
- [ ] Bei Time Series: `AS time` Alias vorhanden
- [ ] Bei Time Series: `ORDER BY time ASC` vorhanden
- [ ] `$__timeFilter` auf die korrekte Timestamp-Spalte angewendet
- [ ] Kein `SELECT *` – immer explizite Spalten
- [ ] Grafana-Variablen korrekte Syntax (`${var}`, `${var:raw}`, `$__timeFilter`)
- [ ] Timezone korrekt behandelt (siehe Macros-Referenz)

## Neue Prompt-Datei erstellen

Falls der User eine neue `prompt_*.md` für ein einzelnes Panel anlegen möchte: Template aus [prompt-template.md](prompt-template.md) lesen und vorausgefüllte Datei im entsprechenden Dashboard-Ordner erstellen.

## Workflow C – Neuen Dashboard-Ordner anlegen

Auslöser: User sagt z.B. „Lege ein neues Dashboard-Verzeichnis an" oder „Erstelle einen neuen Dashboard-Ordner".

### Schritt 1 – Name ermitteln
Falls der Name **nicht im Prompt** enthalten ist, nachfragen:
> „Wie soll das Dashboard heißen? Der Ordnername wird aus dem Namen abgeleitet (Leerzeichen → Bindestrich, Kleinschreibung)."

Falls der Name **im Prompt** enthalten ist, direkt weiter zu Schritt 2.

Ordnernamen-Ableitung:
- Leerzeichen → `-`
- Umlaute: `ä→ae`, `ö→oe`, `ü→ue`, `ß→ss`
- Nur Kleinbuchstaben, Ziffern und Bindestriche
- Beispiel: „P2M Dashboard" → `P2M-dashboard`

### Schritt 2 – Bestätigung einholen
Dem User zeigen, was angelegt wird:
> „Ich lege folgenden Ordner an: `<ordnername>/` mit einer leeren `README.md`. Soll ich fortfahren?"

### Schritt 3 – Ordner und README anlegen
1. Ordner `<ordnername>/` im Workspace-Root erstellen
2. `README.md` aus dem Template in [dashboard-readme-template.md](dashboard-readme-template.md) lesen
3. README mit dem Dashboard-Namen vorausfüllen (Titel + Datenquellen-Standardwerte)
4. Datei als `<ordnername>/README.md` schreiben

### Schritt 4 – User zum nächsten Schritt führen
Nach dem Anlegen mitteilen:
> „Dashboard-Ordner `<ordnername>/` wurde angelegt. Fülle die Panel-Liste im README aus – danach kann ich mit ‚Bootstrappe Prompts für <ordnername>' die Prompt-Grundgerüste generieren."

### Variante – README in bestehendem Verzeichnis anlegen

Auslöser: User sagt z.B. „Lege mir ein README im Verzeichnis `xy` an" und der Ordner existiert bereits.

1. Prüfen ob `<ordner>/README.md` bereits existiert
   - Falls ja: User fragen ob sie überschrieben werden soll, bevor fortgefahren wird
   - Falls nein: direkt weiter
2. Template aus [dashboard-readme-template.md](dashboard-readme-template.md) lesen
3. README mit dem Ordnernamen als Dashboard-Titel vorausfüllen
4. Als `<ordner>/README.md` schreiben
5. Hinweis auf nächsten Schritt geben (Panel-Liste ausfüllen → Bootstrapping)

## Weitere Ressourcen

- Grafana-Macro-Referenz: [grafana-macros.md](grafana-macros.md)
- Prompt-Datei-Template: [prompt-template.md](prompt-template.md)
- Dashboard-README-Template: [dashboard-readme-template.md](dashboard-readme-template.md)
- Tabellendefinitionen: alle Dateien in `resources/` lesen
