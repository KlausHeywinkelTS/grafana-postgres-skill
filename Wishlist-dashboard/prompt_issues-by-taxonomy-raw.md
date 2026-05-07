# Ziel
Zeigt die Anzahl der Issues im Projekt WISH gruppiert nach dem rohen Wert von
customfield_10698 – ohne Splitting, ohne Gruppierung, ohne CASE.
Jeder Jira-Feldwert erscheint exakt so wie er gespeichert ist (inkl. Suffix nach „-").
Beantwortet: „Welche konkreten Taxonomie-Werte sind in WISH-Issues vorhanden und wie häufig?"

# Panel-Typ
Bar Chart

# Tabellen
- jira_issues

# Zeit-Spalte
created_at

# Ausgabe-Spalten
custom_fields->'customfield_10698'->>'value' → "customfield_10698_value"
COUNT(*)                                      → "issue_count"

# Aggregation
COUNT pro Rohwert

# Filter / Bedingungen
- project_key = 'WISH' (hartkodiert)
- (custom_fields->'customfield_10698') IS NOT NULL
- (custom_fields->'customfield_10698') <> 'null'::jsonb  (JSON-null ausschließen)
- description ~* '${source:pipe}' ODER ('Customer Voice Uncensored' ~* '${source:pipe}' AND description ILIKE '%teams message%')

# Grafana-Variablen
- $__timeFilter(created_at)
- ${source:pipe} (Multi-Value, description-Filter)

# Referenz
–

# Hinweise
- Kein split_part, kein btrim, kein CASE – reiner Rohwert für Diagnose/Exploration
- Nützlich um zu prüfen, welche Suffixe nach „-" tatsächlich in den Daten vorkommen
- Sortierung: issue_count DESC, dann customfield_10698_value alphabetisch
