# Ziel
Zeigt die Anzahl der Issues im Projekt WISH gruppiert nach Label.
Beantwortet die Frage: „Welche Labels werden am häufigsten verwendet?"

# Panel-Typ
Bar Chart

# Tabellen
- jira_issues

# Zeit-Spalte
ji.created_at

# Ausgabe-Spalten
lbl          → "label"
COUNT(*)     → "issue_count"

# Aggregation
COUNT pro Label-Kategorie

# Filter / Bedingungen
- project_key = 'WISH' (hartkodiert)
- COALESCE(ji.labels, '') <> '' (leere Labels ausschließen)

# Grafana-Variablen
- $__timeFilter(ji.created_at)

# Referenz
–

# Hinweise
- Labels sind als PostgreSQL-Array-String gespeichert (Format: `{label1,label2}`); die `{}` werden per `trim(both '{}' from ...)` entfernt, dann per `string_to_array(..., ',')` aufgespalten
- CROSS JOIN LATERAL unnest expandiert mehrere Labels einer Issue in separate Zeilen (ein Issue kann mehrfach gezählt werden)
- Sortierung: issue_count DESC, dann label alphabetisch
