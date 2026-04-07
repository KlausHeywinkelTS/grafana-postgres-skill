# Ziel

Monatliche durchschnittliche Cycle Time aller abgeschlossenen Epics. Jedes Epic soll genau dem Monat seines letzten relevanten Statuswechsels zugeordnet werden, und das Ergebnis soll in vier separaten Metriken nach Release Type aufgeteilt werden: Landmark, Maintenance, Enhancement und Experimental.

Das Ergebnis ist fuer ein Bar-Chart gedacht: X-Achse = Monat, Y-Achse = durchschnittliche Cycle Time je Release Type. Obwohl pro Monat vier Balken angezeigt werden, ist die Metrik jeweils ein AVG-Wert und kein COUNT.

## Panel-Typ

Bar chart

## Tabellen

- `jira_issues` (Epics, Release Type in `custom_fields`)
- `jira_issue_changelog` (Statuswechsel fuer Start- und Abschlussdatum des Epics)

## Zeit-Spalte

Letzter relevanter Statuswechsel des Epics aus `jira_issue_changelog.created_at`:

- Prio 1: letzter Wechsel nach `After Release`
- Prio 2: letzter Wechsel nach `Done` oder `Closed`

Dieses Datum wird als `relevant_status_at` verwendet und per `date_trunc('month', relevant_status_at)` auf Monatsebene aggregiert. Zusaetzlich soll eine Monatsserie von `$__timeFrom()` bis `$__timeTo()` erzeugt werden, damit Monate ohne Daten trotzdem im Ergebnis erscheinen.

Der Startpunkt der Cycle Time ist `cycle_start_at` = erster Wechsel des Epics nach `Now`.

## Ausgabe-Spalten

- `month_start` -> `"Monat"`
- `landmark_avg_cycle_time_days` -> `"Landmark"`
- `maintenance_avg_cycle_time_days` -> `"Maintenance"`
- `enhancement_avg_cycle_time_days` -> `"Enhancement"`
- `experimental_avg_cycle_time_days` -> `"Experimental"`

## Aggregation

AVG der Cycle Time pro Monat mit vier bedingten AVG-Metriken, jeweils fuer einen Release Type.

Definition der Cycle Time pro Epic:

- `relevant_status_at - cycle_start_at`
- Ausgabe als Anzahl Tage, idealerweise numerisch/decimal und auf 1 Nachkommastelle gerundet

Jedes Epic soll nur einmal gezaehlt werden, basierend auf seinem priorisierten relevanten Statusdatum.
Als Start der Bearbeitung gilt der erste Statuswechsel nach `Now`.

Fehlende Monate aus der Monatsserie sollen per `LEFT JOIN` ergaenzt werden. Fuer Monate ohne passende Epics sollen die AVG-Spalten `NULL` bleiben, damit keine kuenstliche `0` als Cycle Time interpretiert wird.

## Filter / Bedingungen

- `jira_issues.issue_type = 'Epic'`
- Nur Epics beruecksichtigen, die einen Startwechsel nach `Now` haben
- Nur Epics beruecksichtigen, fuer die ein relevanter Statuswechsel nach `After Release`, `Done` oder `Closed` existiert
- Release Type ueber `e.custom_fields->'customfield_10134'->>'value'` lesen
- Release Type per `ILIKE` in diese vier Gruppen aufteilen:
  - `%Landmark%`
  - `%Maintenance%`
  - `%Enhancement%`
  - `%Experimental%`
- optionaler Ausschluss von Projekten ueber `${exclude_project_keys}`
- Zeitfilter auf `relevant_status_at`, begrenzt durch `$__timeFrom()` und `$__timeTo()`

## Grafana-Variablen

- `$__timeFrom()`
- `$__timeTo()`
- `${exclude_project_keys}`: Multi-Value, optional - Projekte ausschliessen

## Referenz

–

## Hinweise

- Join Changelog zu Issues ueber `jira_issues.issue_key = jira_issue_changelog.issue_key`
- Fuer Statusanalysen in diesem Projekt `to_value` und `from_value` verwenden, nicht `to_display_value` oder `from_display_value`
- Fuer die Statuslogik nur Eintraege mit `field_name = 'status'` verwenden
- Echte Cycle Time bedeutet hier: erster Wechsel nach `Now` bis zum priorisierten Abschlussdatum
- Falls ein Epic mehrfach nach `Now` gewechselt ist, den ersten Wechsel als `cycle_start_at` verwenden
- Falls ein Epic mehrfach nach `After Release`, `Done` oder `Closed` gewechselt ist, die bestehende Priorisierung beibehalten: letzter `After Release`, sonst letzter `Done` oder `Closed`
- Fuer `customfield_10134` immer `ILIKE` statt Exaktvergleich verwenden
- Der Release Type wird ueber `e.custom_fields->'customfield_10134'->>'value'` gelesen
- Fuer ein Bar-Chart ist kein `AS time` noetig; die Monatsachse soll als Kategorie dargestellt werden
- Auch Monate ohne Daten muessen als Zeilen im Ergebnis vorkommen
- Sortierung: Monat aufsteigend
