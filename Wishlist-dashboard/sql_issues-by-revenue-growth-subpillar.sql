-- ============================================================
-- Datei:       sql_issues-by-revenue-growth-subpillar.sql
-- Ziel:        Anzahl der Issues im Projekt WISH aufgeschlüsselt nach den drei
--              Sub-Pillars des Taxonomie-Clusters „Revenue & Growth"
--              (customfield_10698): Reach & Acquisition, Engagement & Conversion,
--              Loyalty & Retention. Matching per LIKE-Präfix.
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter(created_at), ${source:pipe}
-- Basis-SQL:   sql_issues-by-taxonomy.sql
-- Änderungen:  - Sub-Pillars werden einzeln gezeigt statt zu 'Revenue & Growth' zusammengefasst
--              - LIKE-Präfix-Matching statt split_part + btrim
--              - Äußerer WHERE filtert auf genau die drei Sub-Pillars
--              - Sortierung alphabetisch nach category
-- Erstellt:    2026-05-07
-- ============================================================

SELECT
  CASE
    WHEN value LIKE 'Reach & Acquisition%'    THEN 'Reach & Acquisition'
    WHEN value LIKE 'Engagement & Conversion%' THEN 'Engagement & Conversion'
    WHEN value LIKE 'Loyalty & Retention%'     THEN 'Loyalty & Retention'
  END AS category,
  COUNT(*) AS issue_count
FROM (
  SELECT
    custom_fields->'customfield_10698'->>'value' AS value
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
ORDER BY category;
