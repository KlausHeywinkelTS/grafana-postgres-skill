# Ziel
Zeigt die Anzahl der Issues im Projekt WISH gruppiert nach Taxonomie-Pillar (customfield_10698).
Der Rohwert wird am ersten „-" aufgesplittet; nur der Teil vor dem Trennzeichen gilt als Pillar-Name.
Drei Sub-Pillars ('Reach & Acquisition', 'Engagement & Conversion', 'Loyalty & Retention') werden
unter dem Oberbegriff 'Revenue & Growth' zusammengefasst.
Beantwortet: „Wie viele WISH-Issues entfallen auf welchen strategischen Pillar?"

# Panel-Typ
Bar Chart

# Tabellen
- jira_issues

# Zeit-Spalte
created_at

# Ausgabe-Spalten
customfield_10698_group → "customfield_10698_group"
COUNT(*)                → "issue_count"

# Aggregation
COUNT pro Taxonomie-Gruppe (nach CASE-Zusammenfassung)

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
- customfield_10698 ist ein Jira Select-Feld mit Werten wie „Reach & Acquisition - Subtext";
  mit `split_part(..., '-', 1)` und `btrim()` wird nur der Teil vor dem ersten „-" extrahiert.
- CASE-Ausdruck: GROUP BY 1 (Positionsverweis) verweist auf den identischen CASE im SELECT.
- CASE-Gruppierung: 'Reach & Acquisition', 'Engagement & Conversion', 'Loyalty & Retention' → 'Revenue & Growth'
- Sortierung: issue_count DESC, dann customfield_10698_group alphabetisch
