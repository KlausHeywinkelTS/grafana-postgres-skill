-- ============================================================
-- Datei:       sql_epics-p2m-verlauf-monatlich.sql
-- Ziel:        Monatlicher Verlauf Epics mit/ohne P2M-Tasks
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues, jira_issue_changelog
-- Variablen:   $__timeFilter (auf letzten Statuswechsel des Epics)
--              ${exclude_project_keys} (Multi-Value, optional: Projekte ausschließen)
-- Basis-SQL:   –
-- Erstellt:    2026-03-09
-- ============================================================

WITH p2m_parents AS (
  SELECT DISTINCT
    child.parent_key
  FROM jira_issues child
  WHERE child.issue_type = 'P2M Task'
    AND child.parent_key IS NOT NULL
),

last_after_release AS (
  SELECT
    c.issue_id,
    MAX(c.created_at) AS last_after_release_at
  FROM jira_issue_changelog c
  WHERE c.field_name = 'status'
    AND c.to_value = 'After Release'
  GROUP BY c.issue_id
),

last_done_closed AS (
  SELECT
    c.issue_id,
    MAX(c.created_at) AS last_done_closed_at
  FROM jira_issue_changelog c
  WHERE c.field_name = 'status'
    AND c.to_value IN ('Done', 'Closed')
  GROUP BY c.issue_id
),

relevant_status_date AS (
  SELECT
    e.id AS issue_id,
    COALESCE(ar.last_after_release_at, dc.last_done_closed_at) AS relevant_status_at
  FROM jira_issues e
  LEFT JOIN last_after_release ar ON ar.issue_id = e.id
  LEFT JOIN last_done_closed dc   ON dc.issue_id = e.id
  WHERE COALESCE(ar.last_after_release_at, dc.last_done_closed_at) IS NOT NULL
)

SELECT
  date_trunc('month', rsd.relevant_status_at)::date AS "Monat",
  COUNT(*) FILTER (WHERE p.parent_key IS NULL)     AS "Epics ohne P2M-Tasks",
  COUNT(*) FILTER (WHERE p.parent_key IS NOT NULL) AS "Epics mit P2M-Tasks"
FROM relevant_status_date rsd
JOIN jira_issues e ON e.id = rsd.issue_id
LEFT JOIN p2m_parents p ON p.parent_key = e.issue_key
WHERE e.issue_type = 'Epic'
  AND e.custom_fields->'customfield_10112'->>'value' = 'Yes'
  AND (
    '${exclude_project_keys:csv}' = ''
    OR e.project_key NOT IN ($exclude_project_keys)
  )
  AND $__timeFilter(rsd.relevant_status_at)
GROUP BY 1
ORDER BY 1 ASC
