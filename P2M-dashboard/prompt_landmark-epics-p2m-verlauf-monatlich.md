# Prompt: Landmark-Epics P2M Verlauf monatlich

## Ziel

Monatlicher Verlauf aller roadmap-relevanten Landmark-Epics, aufgeteilt in zwei Metriken: Epics MIT mindestens einem P2M-Task und Epics OHNE P2M-Tasks. Die X-Achse soll jeden Monat im gewählten Grafana-Zeitraum zeigen, auch wenn es in einzelnen Monaten keine Epics gibt.

## Panel-Typ

Bar chart

## Tabellen

- `jira_issues` (Epics und P2M-Tasks)
- `jira_issue_changelog` (für den letzten relevanten Statuswechsel des Epics)

## Zeit-Spalte

Letzter relevanter Statuswechsel des Epics:

- Prio 1: letzter Wechsel nach `After Release`
- Prio 2: letzter Wechsel nach `Done` oder `Closed`

Das Datum wird auf Monatsebene mit `date_trunc('month', ...)` aggregiert. Zusätzlich soll eine Monatsserie von `$__timeFrom()` bis `$__timeTo()` erzeugt werden, damit Monate ohne Daten trotzdem im Ergebnis erscheinen.

## Ausgabe-Spalten

- `month_start` → `"Monat"`
- `epics_ohne_p2m_tasks` → `"Epics ohne P2M-Tasks"`
- `epics_mit_p2m_tasks` → `"Epics mit P2M-Tasks"`

## Aggregation

COUNT pro Monat mit zwei bedingten Zählern:

- Ohne P2M: kein Eintrag in den P2M-Parent-Daten für dieses Epic
- Mit P2M: mindestens ein Eintrag in den P2M-Parent-Daten für dieses Epic

Fehlende Monate aus der Monatsserie sollen per `LEFT JOIN` ergänzt und mit `COALESCE(..., 0)` als Nullwerte ausgegeben werden.

## Filter / Bedingungen

- `issue_type = 'Epic'`
- `customfield_10134->>'value' ILIKE '%Landmark Update%'` (nur Landmark-Releases)
- optionaler Ausschluss von Projekten über `${exclude_project_keys}`
- Zeitfilter auf `relevant_status_at`, begrenzt durch `$__timeFrom()` und `$__timeTo()`

## Grafana-Variablen

- `$__timeFrom()`
- `$__timeTo()`
- `${exclude_project_keys}`: Multi-Value, optional - Projekte ausschließen

## Referenz

–

## Hinweise

- Changelog und Issues über `issue_key` verknüpfen, nicht über `issue_id`
- Für Statusvergleiche in `jira_issue_changelog` die Felder `to_value` / `from_value` verwenden
- P2M-Eltern über `child.parent_key` ermitteln; relevante Child-Issues haben `issue_type = 'P2M Task'`
- Für den Landmark-Filter `ILIKE '%Landmark Update%'` statt Exaktvergleich verwenden
- Sortierung aufsteigend nach Monat
