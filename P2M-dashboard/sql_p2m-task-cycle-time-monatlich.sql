-- ============================================================
-- Datei:       sql_p2m-task-cycle-time-monatlich.sql
-- Ziel:        Durchschnittliche Cycle Time geschlossener P2M-Tasks pro Abschlussmonat
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues, jira_issue_changelog
-- Variablen:   $__timeFilter (auf closed_at)
--              ${exclude_project_keys} (Multi-Value, optional: Projekte ausschließen)
-- Basis-SQL:   –
-- Erstellt:    2026-04-07
-- ============================================================

WITH final_close_dates AS (
  SELECT
    c.issue_key,
    MAX(c.created_at) AS closed_at
  FROM jira_issue_changelog c
  WHERE c.field_name = 'status'
    AND c.to_value IN ('Done', 'Rejected')
  GROUP BY c.issue_key
),

closed_p2m_tasks AS (
  SELECT
    t.issue_key,
    t.project_key,
    t.created_at,
    fcd.closed_at,
    EXTRACT(EPOCH FROM (fcd.closed_at - t.created_at)) / 86400.0 AS cycle_time_days
  FROM jira_issues t
  JOIN final_close_dates fcd
    ON fcd.issue_key = t.issue_key
  WHERE t.issue_type = 'P2M Task'
    AND t.created_at IS NOT NULL
    AND t.status IN ('Done', 'Rejected')
)

SELECT
  to_char(date_trunc('month', cpt.closed_at), 'YYYY-MM') AS "Monat",
  ROUND(AVG(cpt.cycle_time_days)::numeric, 1)            AS "Durchschnittliche Cycle Time (Tage)"
FROM closed_p2m_tasks cpt
WHERE (
    '${exclude_project_keys:csv}' = ''
    OR cpt.project_key NOT IN ($exclude_project_keys)
  )
  AND $__timeFilter(cpt.closed_at)
GROUP BY date_trunc('month', cpt.closed_at)
ORDER BY date_trunc('month', cpt.closed_at) ASC
