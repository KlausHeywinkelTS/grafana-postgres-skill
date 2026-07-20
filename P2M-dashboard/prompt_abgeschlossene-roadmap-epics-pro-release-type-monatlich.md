# Ziel

Monatliche Anzahl abgeschlossener, roadmap-relevanter Epics, aufgeteilt in vier separate Metriken nach Release Type: Landmark, Maintenance, Enhancement und Experimental.

Das Ergebnis ist fuer ein Bar-Chart gedacht: X-Achse = Monat, Y-Achse = Anzahl abgeschlossener Epics je Release Type. Pro Monat sollen vier Balken bzw. vier Metrikwerte ausgegeben werden.

## Panel-Typ

Bar chart

## Tabellen

- `jira_issues` (Epics, Relevant for Roadmap und Release Type in `custom_fields`)
- `jira_issue_changelog` (Statuswechsel fuer das Abschlussdatum des Epics)

## Zeit-Spalte

Letzter relevanter Abschluss-Statuswechsel des Epics aus `jira_issue_changelog.created_at`:

- Prio 1: letzter Wechsel nach `After Release`
- Prio 2: letzter Wechsel nach `Done` oder `Closed`

Dieses Datum wird als `relevant_status_at` verwendet und per `date_trunc('month', relevant_status_at)` auf Monatsebene aggregiert.

## Ausgabe-Spalten

- `month` -> `"Monat"`
- `landmark_epics_count` -> `"Landmark"`
- `maintenance_epics_count` -> `"Maintenance"`
- `enhancement_epics_count` -> `"Enhancement"`
- `experimental_epics_count` -> `"Experimental"`

## Aggregation

COUNT pro Monat mit vier bedingten Zaehlern, jeweils fuer einen Release Type.

Jedes Epic soll nur einmal gezaehlt werden, basierend auf seinem priorisierten relevanten Abschlussdatum.

## Filter / Bedingungen

- `jira_issues.issue_type = 'Epic'`
- Nur Epics beruecksichtigen, fuer die ein relevanter Statuswechsel nach `After Release`, `Done` oder `Closed` existiert
- Release Type ueber `e.custom_fields->'customfield_10134'->>'value'` lesen
- Release Type per `ILIKE` in diese vier Gruppen aufteilen:
- `%Landmark%`
- `%Maintenance%`
- `%Enhancement%`
- `%Experiment%`
- optionale Ausschluesse von Projekten ueber `${exclude_project_keys}`
- Zeitfilter auf `relevant_status_at` in der aeussersten `WHERE`-Klausel

## Grafana-Variablen

- `$__timeFilter` auf `relevant_status_at`
- `${exclude_project_keys}`: Multi-Value, optional - Projekte ausschliessen

## Referenz

–

## Hinweise

- Join Changelog zu Issues ueber `jira_issues.issue_key = jira_issue_changelog.issue_key`
- Fuer Statusanalysen in diesem Projekt `to_value` und `from_value` verwenden, nicht `to_display_value` oder `from_display_value`
- Fuer die Statuslogik nur Eintraege mit `field_name = 'status'` verwenden
- Fuer `customfield_10134` immer `ILIKE` statt Exaktvergleich verwenden
- Falls ein Epic mehrfach nach `After Release`, `Done` oder `Closed` gewechselt ist, die bestehende Priorisierung beibehalten: letzter `After Release`, sonst letzter `Done` oder `Closed`
- Fuer ein Bar-Chart ist kein `AS time` noetig; die Monatsachse soll als Kategorie dargestellt werden
- Sortierung: Monat aufsteigend
