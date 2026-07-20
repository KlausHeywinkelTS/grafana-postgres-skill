-- ============================================================
-- Datei:       sql_landmark-epics-p2m-verlauf-monatlich.sql
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

months AS (
  SELECT
    generate_series(
      date_trunc('month', $__timeFrom()::timestamp),
      date_trunc('month', $__timeTo()::timestamp),
      interval '1 month'
    )::date AS month_start
),

last_after_release AS (
  SELECT
    c.issue_key,
    MAX(c.created_at) AS last_after_release_at
  FROM jira_issue_changelog c
  WHERE c.field_name = 'status'
    AND c.to_value = 'After Release'
  GROUP BY c.issue_key
),

last_done_closed AS (
  SELECT
    c.issue_key,
    MAX(c.created_at) AS last_done_closed_at
  FROM jira_issue_changelog c
  WHERE c.field_name = 'status'
    AND c.to_value IN ('Done', 'Closed')
  GROUP BY c.issue_key
),

relevant_status_date AS (
  SELECT
    e.issue_key,
    COALESCE(ar.last_after_release_at, dc.last_done_closed_at) AS relevant_status_at
  FROM jira_issues e
  LEFT JOIN last_after_release ar ON ar.issue_key = e.issue_key
  LEFT JOIN last_done_closed dc   ON dc.issue_key = e.issue_key
  WHERE COALESCE(ar.last_after_release_at, dc.last_done_closed_at) IS NOT NULL
),

landmark_epics AS (
  SELECT
    date_trunc('month', rsd.relevant_status_at)::date AS month_start,
    p.parent_key
  FROM relevant_status_date rsd
  JOIN jira_issues e ON e.issue_key = rsd.issue_key
  LEFT JOIN p2m_parents p ON p.parent_key = e.issue_key
  WHERE e.issue_type = 'Epic'
    AND e.custom_fields->'customfield_10134'->>'value' ILIKE '%Landmark Update%'
    AND (
      '${exclude_project_keys:csv}' = ''
      OR e.project_key NOT IN ($exclude_project_keys)
    )
    AND rsd.relevant_status_at >= $__timeFrom()
    AND rsd.relevant_status_at <= $__timeTo()
),

monthly_counts AS (
  SELECT
    le.month_start,
    COUNT(*) FILTER (WHERE le.parent_key IS NULL)     AS epics_ohne_p2m_tasks,
    COUNT(*) FILTER (WHERE le.parent_key IS NOT NULL) AS epics_mit_p2m_tasks
  FROM landmark_epics le
  GROUP BY le.month_start
)

SELECT
  m.month_start                                     AS "Monat",
  COALESCE(mc.epics_ohne_p2m_tasks, 0)             AS "Epics ohne P2M-Tasks",
  COALESCE(mc.epics_mit_p2m_tasks, 0)              AS "Epics mit P2M-Tasks"
FROM months m
LEFT JOIN monthly_counts mc ON mc.month_start = m.month_start
ORDER BY 1 ASC
