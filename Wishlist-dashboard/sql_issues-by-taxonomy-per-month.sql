-- ============================================================
-- Datei:       sql_issues-by-taxonomy-per-month.sql
-- Ziel:        Monatliche Anzahl neuer Issues im Projekt WISH als Time Series,
--              aufgeschlüsselt nach Taxonomie-Pillar (customfield_10698) –
--              eine Spalte pro Pillar, Revenue & Growth Sub-Pillars zusammengefasst.
-- Panel-Typ:   Time Series
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter(created_at), ${source:pipe}
-- Basis-SQL:   sql_issues-by-taxonomy.sql
-- Änderungen:  - Time Series statt Bar Chart; Granularität: Monat
--              - Pivot via COUNT(*) FILTER: eine Spalte pro Pillar
--              - Sortierung time ASC
-- Erstellt:    2026-05-07
-- ============================================================

SELECT
  date_trunc('month', t.created_at) AS "time",

  COUNT(*) FILTER (
    WHERE base_value IN (
      'Reach & Acquisition',
      'Engagement & Conversion',
      'Loyalty & Retention'
    )
  ) AS "Revenue & Growth",

  COUNT(*) FILTER (
    WHERE base_value = 'Trust & Risk'
  ) AS "Trust & Risk",

  COUNT(*) FILTER (
    WHERE base_value = 'Operational Excellence'
  ) AS "Operational Excellence",

  COUNT(*) FILTER (
    WHERE base_value = 'Platform & Ecosystem'
  ) AS "Platform & Ecosystem"

FROM (
  SELECT
    ji.created_at,
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
ORDER BY 1;
