-- ============================================================
-- Datei:       sql_issues-by-taxonomy-full.sql
-- Ziel:        Anzahl der Issues im Projekt WISH gruppiert nach Taxonomie-Pillar
--              (customfield_10698); Sub-Pillars von Revenue & Growth werden mit
--              vollständigem Präfix ausgewiesen (z.B. „Revenue & Growth | Reach &
--              Acquisition"), alle anderen Pillars unverändert.
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter(created_at), ${source:pipe}
-- Basis-SQL:   sql_issues-by-taxonomy.sql
-- Änderungen:  - Sub-Pillars werden nicht zusammengefasst, sondern mit Präfix benannt
--              - Sortierung alphabetisch nach customfield_10698_group
-- Erstellt:    2026-05-07
-- ============================================================

SELECT
  CASE
    WHEN base_value = 'Reach & Acquisition'
      THEN 'Revenue & Growth | Reach & Acquisition'
    WHEN base_value = 'Engagement & Conversion'
      THEN 'Revenue & Growth | Engagement & Conversion'
    WHEN base_value = 'Loyalty & Retention'
      THEN 'Revenue & Growth | Loyalty & Retention'
    ELSE base_value
  END AS customfield_10698_group,
  COUNT(*) AS issue_count
FROM (
  SELECT
    btrim(
      split_part(
        ji.custom_fields->'customfield_10698'->>'value',
        '-',
        1
      )
    ) AS base_value
  FROM jira_issues ji
  WHERE ji.project_key = 'WISH'
    AND $__timeFilter(ji.created_at)
    AND (ji.custom_fields->'customfield_10698') IS NOT NULL
    AND (ji.custom_fields->'customfield_10698') <> 'null'::jsonb
    AND (
      ji.description ~* '${source:pipe}'
      OR (
        '${source:pipe}' ~* 'Customer Voice Uncensored'
        AND ji.description ILIKE '%teams message%'
      )
    )
) t
GROUP BY 1
ORDER BY customfield_10698_group;
