-- ============================================================
-- Datei:       sql_issues-by-revenue-growth-subpillar-per-month.sql
-- Ziel:        Monatliche Anzahl neuer Issues im Projekt WISH als Time Series,
--              aufgeschlüsselt nach den drei Sub-Pillars von Revenue & Growth
--              (customfield_10698): Reach & Acquisition, Engagement & Conversion,
--              Loyalty & Retention – je eine Spalte. Matching per LIKE-Präfix.
-- Panel-Typ:   Time Series
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter(created_at), ${source:pipe}
-- Basis-SQL:   sql_issues-by-revenue-growth-subpillar.sql
-- Änderungen:  - Time Series statt Bar Chart; Granularität: Monat
--              - Pivot via COUNT(*) FILTER: eine Spalte pro Sub-Pillar
--              - Sortierung time ASC
-- Erstellt:    2026-05-07
-- ============================================================

SELECT
  date_trunc('month', t.created_at) AS "time",

  COUNT(*) FILTER (
    WHERE value LIKE 'Reach & Acquisition%'
  ) AS "Reach & Acquisition",

  COUNT(*) FILTER (
    WHERE value LIKE 'Engagement & Conversion%'
  ) AS "Engagement & Conversion",

  COUNT(*) FILTER (
    WHERE value LIKE 'Loyalty & Retention%'
  ) AS "Loyalty & Retention"

FROM (
  SELECT
    ji.created_at,
    ji.custom_fields->'customfield_10698'->>'value' AS value
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
WHERE value LIKE 'Reach & Acquisition%'
   OR value LIKE 'Engagement & Conversion%'
   OR value LIKE 'Loyalty & Retention%'
GROUP BY 1
ORDER BY 1;
