# Ziel

Zeigt die Anzahl neu erstellter Issues im Projekt WISH gruppiert nach Monat.
Beantwortet die Frage: „Wie viele Issues wurden pro Monat angelegt?"

## Panel-Typ

Time Series

## Tabellen

- jira_issues

## Zeit-Spalte

ji.created_at

## Ausgabe-Spalten

date_trunc('month', ji.created_at) → "month"
COUNT(*)                           → "issue_count"

## Aggregation

COUNT pro Monat (date_trunc('month', created_at))

## Filter / Bedingungen

- project_key = 'WISH' (hartkodiert)

## Grafana-Variablen

- $__timeFilter(ji.created_at)

## Referenz

– None

## Hinweise

- GROUP BY 1, ORDER BY 1 (nach Monat aufsteigend)
- project_key ist derzeit hartkodiert; bei Bedarf durch ${project} ersetzen
