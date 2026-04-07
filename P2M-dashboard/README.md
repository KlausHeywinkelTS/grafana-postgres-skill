# Dashboard: P2M Dashboard

## Zweck

Visualisierung wichtiger Metriken für den Product-to-Market Prozess (auch Product-2-Market oder kurz P2M genannt). Der Prozess beschreibt, wie mit Hilfe von Epics und direkten Child-issues vom issue-type "P2M Task" ein Release vorbereitet wird.

P2M-Tasks beschreiben die Zulieferung von anderen Abteilungen (z.B. Marketing, Content, Enablement) für ein Feature-Update oder ein neues Feature, welches in der Produktentwicklung eines SaaS Unternehmens entwickelt wird.

Es gilt im Unternehmen die Regel: Jedes Epic in Jira steht für ein Release.

## Zielgruppe

- Product Operations
- Produkt-Management
- Stakeholder

## Datenquellen

- jira_issues
- jira_issue_changelog

## Dashboard-Variablen (Grafana)

- `$__timeFilter`: Standard-Grafana-Zeitfilter; angewendet auf das **letzte Status-Wechsel-Datum des Epics** (siehe Zeitraum)
- `${exclude_project_keys}`: Multi-Value-Variable zum Ausschließen von Projekten nach `project_key`. Leer = kein Ausschluss. Werte über `sql_variable-projekt-keys.sql` befüllen.

## Wichtige Felddefinitionen

### `customfield_10112` - Relevant for Roadmap

- Zugriff: `e.custom_fields->'customfield_10112'->>'value'`
- Moegliche Werte: `Yes`, `No`, `None`
- Wenn das Dashboard roadmap-relevante Epics meint, ist `Yes` der relevante Filterwert
- Diese Definition ist fuer das `P2M-dashboard` immer zu beruecksichtigen

### `customfield_10134` - Release Type

- Zugriff: `e.custom_fields->'customfield_10134'->>'value'`
- Pruefung ueber Teilstrings mit `ILIKE`
- `ILIKE '%Landmark%'` steht fuer Landmark Releases
- `ILIKE '%Enhancement%'` steht fuer Enhancement Releases
- `ILIKE '%Maintenance%'` steht fuer Maintenance Releases
- `ILIKE '%Experiment%'` steht fuer Experimental Releases

### Epic-Cycle-Time: Startstatus

- Fuer die Cycle Time von Epics ist der fachliche Startstatus `Now`
- `In Progress` ist fuer Epic-Cycle-Time in diesem Dashboard nicht der richtige Statuswert
- Wenn eine SQL die Epic-Cycle-Time berechnet, muss der Startpunkt aus dem ersten Statuswechsel nach `Now` ermittelt werden
- Diese Definition ist fuer das `P2M-dashboard` bei allen Epic-Cycle-Time-Abfragen zu beruecksichtigen

## Zeitraum

Der Zeitfilter bezieht sich auf das letzte Datum, wann ein Epic in den Status **„After Release"** gewechselt hat.
Falls ein Epic nie den Status „After Release" erreicht hat, gilt alternativ das letzte Datum des Wechsels in **„Done"** oder **„Closed"**.

Dieses Datum wird aus `jira_issue_changelog` ermittelt: `to_value IN ('After Release', 'Done', 'Closed')`, priorisiert in dieser Reihenfolge (After Release > Done/Closed).

## Panels

### Panel: Landmark-Release mit P2M-Tasks

- **Typ**: Stat
- **Beschreibung**: Prozentsatz der Landmark-Releases (Epics mit Release Type = „Landmark Update"), die mindestens einen P2M-Task als Child-Issue haben, in Relation zur Gesamtanzahl aller Landmark-Releases im gewählten Zeitraum.
- **Metriken / Spalten**: %-Wert (Anzahl Landmark-Epics mit mind. einem P2M-Task / Anzahl aller Landmark-Epics × 100)
- **Filter**:
  - `issue_type = 'Epic'`
  - `customfield_10112->>'value' = 'Yes'` (Relevant for Roadmap, Großschreibung)
  - `customfield_10134 = 'Landmark Update (major changes for customers)'` (Release Type)
  - Zeitraum: letzter Statuswechsel nach „After Release" (Prio 1), sonst „Done" oder „Closed" (Prio 2) – Datum aus `jira_issue_changelog`
- **Aggregation**: COUNT mit Bedingung (zwei Zähler: Gesamt-Landmark-Epics vs. Landmark-Epics mit mind. einem P2M-Task)
- **Hinweise**:
  - Child-Issues sind über `parent_key` verknüpft: `child.parent_key = epic.issue_key`
  - P2M-Tasks haben `issue_type = 'P2M Task'` (exakter Wert)
  - Landmark-Release ≠ „Relevant for Roadmap" – beide Custom Fields sind unabhängig voneinander
  - Epics, die nie einen der genannten Status erreicht haben, fallen aus dem Zeitfilter heraus

## Offene Fragen / TODOs
