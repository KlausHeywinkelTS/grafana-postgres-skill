-- ============================================================
-- Datei:       sql_abgeschlossene-roadmap-epics-pro-release-type-monatlich.sql
-- Ziel:        Monatliche Anzahl abgeschlossener, roadmap-relevanter Epics,
--              aufgeteilt nach Release Type
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues, jira_issue_changelog
-- Variablen:   $__timeFilter (auf relevant_status_at)
--              ${exclude_project_keys} (Multi-Value, optional: Projekte ausschliessen)
-- Basis-SQL:   –
-- Erstellt:    2026-04-07
-- ============================================================

WITH after_release_dates AS (
  SELECT
    c.issue_key,
    MAX(c.created_at) AS after_release_at
  FROM jira_issue_changelog c
  WHERE c.field_name = 'status'
    AND c.to_value = 'After Release'
  GROUP BY c.issue_key
),

done_closed_dates AS (
  SELECT
    c.issue_key,
    MAX(c.created_at) AS done_closed_at
  FROM jira_issue_changelog c
  WHERE c.field_name = 'status'
    AND c.to_value IN ('Done', 'Closed')
  GROUP BY c.issue_key
),

relevant_end_dates AS (
  SELECT
    COALESCE(ard.issue_key, dcd.issue_key)             AS issue_key,
    ard.after_release_at,
    dcd.done_closed_at,
    COALESCE(ard.after_release_at, dcd.done_closed_at) AS relevant_status_at
  FROM after_release_dates ard
  FULL OUTER JOIN done_closed_dates dcd
    ON dcd.issue_key = ard.issue_key
),

roadmap_epics AS (
  SELECT
    e.issue_key,
    e.project_key,
    red.relevant_status_at,
    CASE
      WHEN e.custom_fields->'customfield_10134'->>'value' ILIKE '%Landmark%' THEN 'Landmark'
      WHEN e.custom_fields->'customfield_10134'->>'value' ILIKE '%Maintenance%' THEN 'Maintenance'
      WHEN e.custom_fields->'customfield_10134'->>'value' ILIKE '%Enhancement%' THEN 'Enhancement'
      WHEN e.custom_fields->'customfield_10134'->>'value' ILIKE '%Experiment%' THEN 'Experimental'
      ELSE NULL
    END AS release_type_group
  FROM jira_issues e
  JOIN relevant_end_dates red
    ON red.issue_key = e.issue_key
  WHERE e.issue_type = 'Epic'
    AND e.custom_fields->'customfield_10112'->>'value' = 'Yes'
    AND red.relevant_status_at IS NOT NULL
)

SELECT
  date_trunc('month', re.relevant_status_at)::date AS "Monat",
  COUNT(*) FILTER (WHERE re.release_type_group = 'Landmark')     AS "Landmark",
  COUNT(*) FILTER (WHERE re.release_type_group = 'Maintenance')  AS "Maintenance",
  COUNT(*) FILTER (WHERE re.release_type_group = 'Enhancement')  AS "Enhancement",
  COUNT(*) FILTER (WHERE re.release_type_group = 'Experimental') AS "Experimental"
FROM roadmap_epics re
WHERE re.release_type_group IS NOT NULL
  AND (
    '${exclude_project_keys:csv}' = ''
    OR re.project_key NOT IN ($exclude_project_keys)
  )
  AND $__timeFilter(re.relevant_status_at)
GROUP BY 1
ORDER BY 1 ASC;
