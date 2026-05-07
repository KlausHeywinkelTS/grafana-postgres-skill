# Ziel
Zeigt die monatliche Anzahl neuer Issues im Projekt WISH als Time Series, aufgeschlüsselt nach
Taxonomie-Pillar (customfield_10698) – eine Spalte pro Pillar.
Die drei Sub-Pillars von Revenue & Growth werden zusammengezählt.
Beantwortet: „Wie entwickeln sich die Issue-Zahlen pro strategischen Pillar über die Zeit?"

# Panel-Typ
Time Series

# Tabellen
- jira_issues

# Zeit-Spalte
created_at

# Ausgabe-Spalten
date_trunc('month', created_at) → "time"
COUNT(*) FILTER (Revenue & Growth Sub-Pillars) → "Revenue & Growth"
COUNT(*) FILTER (base_value = 'Trust & Risk') → "Trust & Risk"
COUNT(*) FILTER (base_value = 'Operational Excellence') → "Operational Excellence"
COUNT(*) FILTER (base_value = 'Platform & Ecosystem') → "Platform & Ecosystem"

# Aggregation
COUNT pro Monat und Pillar (Pivot via COUNT(*) FILTER)

# Filter / Bedingungen
- project_key = 'WISH' (hartkodiert)
- (custom_fields->'customfield_10698') IS NOT NULL
- (custom_fields->'customfield_10698') <> 'null'::jsonb  (JSON-null ausschließen)
- description ~* '${source:pipe}' ODER ('Customer Voice Uncensored' ~* '${source:pipe}' AND description ILIKE '%teams message%')

# Grafana-Variablen
- $__timeFilter(created_at)
- ${source:pipe} (Multi-Value, description-Filter)

# Referenz
Wie sql_issues-by-taxonomy.sql – aber mit folgenden Änderungen:
- Panel-Typ Time Series statt Bar Chart
- Pivot: ein COUNT(*) FILTER-Ausdruck pro Pillar als separate Spalte (nicht GROUP BY Pillar)
- Revenue & Growth fasst die drei Sub-Pillars zusammen (identisch zu issues-by-taxonomy)
- Monatliche Granularität via date_trunc('month', created_at)
- Sortierung aufsteigend nach time

# Hinweise
- Pivot-Technik: COUNT(*) FILTER (WHERE ...) erzeugt pro Pillar eine eigene Spalte –
  Grafana interpretiert diese automatisch als separate Zeitreihen in der Legende
- btrim(split_part(..., '-', 1)) extrahiert den Teil vor dem ersten „-" als Basis-Wert
- Sortierung: time ASC (Pflicht für Time Series)
