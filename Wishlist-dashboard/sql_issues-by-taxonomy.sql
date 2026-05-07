-- ============================================================
-- Datei:       sql_issues-by-taxonomy.sql
-- Ziel:        Anzahl der Issues im Projekt WISH gruppiert nach Taxonomie-Pillar
--              (customfield_10698); Basis-Wert = Teil vor dem ersten „-";
--              'Reach & Acquisition', 'Engagement & Conversion', 'Loyalty & Retention'
--              werden zu 'Revenue & Growth' zusammengefasst.
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter(created_at), ${source:pipe}
-- Basis-SQL:   –
-- Erstellt:    2026-04-23
-- ============================================================

SELECT
  CASE
    WHEN base_value IN (
      'Reach & Acquisition',
      'Engagement & Conversion',
      'Loyalty & Retention'
    )
      THEN 'Revenue & Growth'
    ELSE base_value
  END AS customfield_10698_group,
  COUNT(*) AS issue_count
FROM (
  SELECT
    btrim(
      split_part(
        custom_fields->'customfield_10698'->>'value',
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
ORDER BY issue_count DESC, customfield_10698_group;
