# Ziel
Zeigt die monatliche Anzahl neuer Issues im Projekt WISH als Time Series, aufgeschlüsselt nach
den drei Sub-Pillars von „Revenue & Growth" (customfield_10698):
Reach & Acquisition, Engagement & Conversion, Loyalty & Retention – je eine Spalte.
Matching per LIKE-Präfix; Issues anderer Pillars werden ausgeblendet.
Beantwortet: „Wie entwickeln sich die drei Revenue-&-Growth-Sub-Pillars über die Zeit?"

# Panel-Typ
Time Series

# Tabellen
- jira_issues

# Zeit-Spalte
created_at

# Ausgabe-Spalten
date_trunc('month', created_at) → "time"
COUNT(*) FILTER (LIKE 'Reach & Acquisition%')    → "Reach & Acquisition"
COUNT(*) FILTER (LIKE 'Engagement & Conversion%') → "Engagement & Conversion"
COUNT(*) FILTER (LIKE 'Loyalty & Retention%')     → "Loyalty & Retention"

# Aggregation
COUNT pro Monat und Sub-Pillar (Pivot via COUNT(*) FILTER)

# Filter / Bedingungen
- project_key = 'WISH' (hartkodiert)
- (custom_fields->'customfield_10698') IS NOT NULL
- (custom_fields->'customfield_10698') <> 'null'::jsonb  (JSON-null ausschließen)
- Äußerer WHERE: value LIKE 'Reach & Acquisition%' OR 'Engagement & Conversion%' OR 'Loyalty & Retention%'
- description ~* '${source:pipe}' ODER ('Customer Voice Uncensored' ~* '${source:pipe}' AND description ILIKE '%teams message%')

# Grafana-Variablen
- $__timeFilter(created_at)
- ${source:pipe} (Multi-Value, description-Filter)

# Referenz
Wie sql_issues-by-revenue-growth-subpillar.sql – aber mit folgenden Änderungen:
- Panel-Typ Time Series statt Bar Chart
- Pivot via COUNT(*) FILTER: eine Spalte pro Sub-Pillar
- Monatliche Granularität via date_trunc('month', created_at)
- Sortierung time ASC

# Hinweise
- LIKE-Präfix-Matching ist robuster als split_part, wenn Suffixe variieren
- Pivot-Technik: COUNT(*) FILTER erzeugt pro Sub-Pillar eine eigene Spalte –
  Grafana interpretiert diese automatisch als separate Zeitreihen
- Äußerer WHERE stellt sicher, dass keine NULL-Werte aus dem FILTER in die Ergebnismenge gelangen
- Sortierung: time ASC (Pflicht für Time Series)
