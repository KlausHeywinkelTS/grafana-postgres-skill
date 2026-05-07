# Ziel
Zeigt die Anzahl der Issues im Projekt WISH gruppiert nach Taxonomie-Pillar (customfield_10698).
Die drei Sub-Pillars von „Revenue & Growth" werden mit vollständigem Präfix ausgewiesen
(z.B. „Revenue & Growth | Reach & Acquisition"), alle anderen Pillars erscheinen unverändert.
Basis-Wert = Teil vor dem ersten „-" (split_part + btrim).
Beantwortet: „Wie viele WISH-Issues entfallen auf welchen Pillar – mit klarer Hierarchie-Beschriftung?"

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
COUNT pro Taxonomie-Gruppe (nach CASE-Umbenennung)

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
- Sub-Pillars werden NICHT zu 'Revenue & Growth' zusammengefasst, sondern mit Präfix ausgewiesen:
    'Reach & Acquisition'      → 'Revenue & Growth | Reach & Acquisition'
    'Engagement & Conversion'  → 'Revenue & Growth | Engagement & Conversion'
    'Loyalty & Retention'      → 'Revenue & Growth | Loyalty & Retention'
- Alle anderen Pillars: ELSE base_value (unverändert)
- Sortierung alphabetisch nach customfield_10698_group (nicht nach issue_count)

# Hinweise
- split_part(..., '-', 1) + btrim() extrahiert den Teil vor dem ersten „-" als Basis-Wert
- CASE-Ausdruck: GROUP BY 1 (Positionsverweis) verweist auf den identischen CASE im SELECT
- Sortierung: alphabetisch nach customfield_10698_group
