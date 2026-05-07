# Ziel
Zeigt die Anzahl der WISH-Issues, die im gewählten Zeitraum angelegt wurden, den source-Filter berücksichtigen UND im Feld „Value Driver" (customfield_10698) einen befüllten Wert haben.
Beantwortet die Frage: „Wie viele Wishes mit befülltem Value Driver wurden im Filterzeitraum und für die ausgewählte Source angelegt?"

# Panel-Typ
Stat

# Tabellen
- jira_issues

# Zeit-Spalte
created_at

# Ausgabe-Spalten
COUNT(*) → "Wishes mit Value Driver"

# Aggregation
COUNT (Einzelwert)

# Filter / Bedingungen
- project_key = 'WISH' (hartkodiert)
- $__timeFilter(created_at)
- ${source:pipe} (Multi-Value, description-Filter; gleiche Logik wie in sql_issues-by-taxonomy.sql)
- (custom_fields->'customfield_10698') IS NOT NULL
- (custom_fields->'customfield_10698') <> 'null'::jsonb  (JSON-null ausschließen)

# Grafana-Variablen
- $__timeFilter(created_at)
- ${source:pipe} (Multi-Value, description-Filter)

# Referenz
Wie sql_issues-by-taxonomy.sql – aber mit folgenden Änderungen:
- Kein GROUP BY, kein CASE – nur ein einzelner COUNT(*)
- Kein Aufschlüsseln nach Taxonomie-Gruppe; der Filter auf befülltes customfield_10698 reicht
- Panel-Typ Stat statt Bar Chart

# Hinweise
- Zugriff auf den Feldwert: custom_fields->'customfield_10698'->>'value'
- Ein Issue gilt als „mit Value Driver" wenn das JSONB-Feld existiert und nicht JSON-null ist
- source-Filter: gleiche Logik wie sql_issues-by-taxonomy.sql (description ~* '${source:pipe}' OR Customer Voice Uncensored + teams message)
