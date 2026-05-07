# Ziel
Zeigt die Anzahl der Issues im Projekt WISH aufgeschlüsselt nach den drei Sub-Pillars des
Taxonomie-Clusters „Revenue & Growth" (customfield_10698):
'Reach & Acquisition', 'Engagement & Conversion', 'Loyalty & Retention'.
Der Rohwert wird per LIKE-Präfix-Match ('X%') zugeordnet, sodass auch Werte mit Suffix
(z.B. „Reach & Acquisition - Subtext") korrekt erfasst werden.
Beantwortet: „Wie viele WISH-Issues entfallen auf welchen Sub-Pillar von Revenue & Growth?"

# Panel-Typ
Bar Chart

# Tabellen
- jira_issues

# Zeit-Spalte
created_at

# Ausgabe-Spalten
category     → "category"
COUNT(*)     → "issue_count"

# Aggregation
COUNT pro Sub-Pillar-Kategorie

# Filter / Bedingungen
- project_key = 'WISH' (hartkodiert)
- (custom_fields->'customfield_10698') IS NOT NULL
- (custom_fields->'customfield_10698') <> 'null'::jsonb  (JSON-null ausschließen)
- Äußerer WHERE: value LIKE 'Reach & Acquisition%' OR 'Engagement & Conversion%' OR 'Loyalty & Retention%'
  (Werte außerhalb dieser drei Sub-Pillars werden ausgeschlossen)
- description ~* '${source:pipe}' ODER ('Customer Voice Uncensored' ~* '${source:pipe}' AND description ILIKE '%teams message%')

# Grafana-Variablen
- $__timeFilter(created_at)
- ${source:pipe} (Multi-Value, description-Filter)

# Referenz
Wie sql_issues-by-taxonomy.sql – aber mit folgenden Änderungen:
- Kein Zusammenfassen zu 'Revenue & Growth'; stattdessen werden die drei Sub-Pillars einzeln gezeigt
- Matching per LIKE-Präfix statt split_part + btrim
- Äußerer WHERE-Filter schließt alle anderen Taxonomie-Werte aus
- Sortierung alphabetisch nach category (nicht nach issue_count)

# Hinweise
- LIKE 'X%' ist robuster als split_part(..., '-', 1), wenn Suffixe variieren (z.B. mit oder ohne „-")
- CASE im SELECT deckt nur die drei bekannten Sub-Pillars ab; der äußere WHERE stellt sicher,
  dass kein NULL-Wert aus dem CASE in die Ergebnismenge gelangt
- Sortierung: alphabetisch nach category
