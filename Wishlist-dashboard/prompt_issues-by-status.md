# Ziel
Zeigt die Anzahl der Issues im Projekt WISH gruppiert nach Status.
Beantwortet die Frage: „Wie viele Issues befinden sich aktuell in welchem Status?"

# Panel-Typ
Bar Chart

# Tabellen
- jira_issues

# Zeit-Spalte
ji.created_at

# Ausgabe-Spalten
s.status    → "status"
COUNT(ji.id) → "issue_count"

# Aggregation
COUNT pro Status-Kategorie

# Filter / Bedingungen
- project_key = 'WISH' (hartkodiert)

# Grafana-Variablen
- $__timeFilter(ji.created_at) – angewendet im LEFT JOIN ON, nicht im WHERE

# Referenz
–

# Hinweise
- CTE `all_statuses` stellt sicher, dass alle Status-Werte erscheinen, auch wenn im Zeitraum keine Issues vorhanden sind (LEFT JOIN)
- $__timeFilter liegt im JOIN ON-Clause (nicht in einem CTE WHERE) – regelkonform
- WHERE ji.project_key = 'WISH' nach dem LEFT JOIN wandelt nicht vorhandene Status effektiv in 0-Zeilen um; ggf. prüfen ob NULL-Handling gewünscht ist
- ORDER BY s.status (alphabetisch)
