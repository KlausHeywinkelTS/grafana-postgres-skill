-- ============================================================
-- Datei:       sql_epics-cycle-time-pro-release-type-monatlich.sql
-- Ziel:        Durchschnittliche Cycle Time abgeschlossener Epics pro Monat,
--              aufgeteilt nach Release Type
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues, jira_issue_changelog
-- Variablen:   $__timeFrom(), $__timeTo() (Monatsserie und Filter auf relevant_status_at)
--              ${exclude_project_keys} (Multi-Value, optional: Projekte ausschließen)
-- Basis-SQL:   –
-- Erstellt:    2026-04-07
-- ============================================================

WITH months AS (
  SELECT
    generate_series(
      date_trunc('month', $__timeFrom()::timestamp),
      date_trunc('month', $__timeTo()::timestamp),
      interval '1 month'
    )::date AS month_start
),

cycle_start_dates AS (
  SELECT
    c.issue_key,
    MIN(c.created_at) AS cycle_start_at
  FROM jira_issue_changelog c
  WHERE c.field_name = 'status'
    AND c.to_value = 'Now'
  GROUP BY c.issue_key
),

after_release_dates AS (
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
    COALESCE(ard.issue_key, dcd.issue_key)            AS issue_key,
    ard.after_release_at,
    dcd.done_closed_at,
    COALESCE(ard.after_release_at, dcd.done_closed_at) AS relevant_status_at
  FROM after_release_dates ard
  FULL OUTER JOIN done_closed_dates dcd
    ON dcd.issue_key = ard.issue_key
),

epics_with_cycle_time AS (
  SELECT
    e.issue_key,
    e.project_key,
    date_trunc('month', red.relevant_status_at)::date AS month_start,
    e.custom_fields->'customfield_10134'->>'value' AS release_type_raw,
    CASE
      WHEN e.custom_fields->'customfield_10134'->>'value' ILIKE '%Landmark%' THEN 'Landmark'
      WHEN e.custom_fields->'customfield_10134'->>'value' ILIKE '%Maintenance%' THEN 'Maintenance'
      WHEN e.custom_fields->'customfield_10134'->>'value' ILIKE '%Enhancement%' THEN 'Enhancement'
      WHEN e.custom_fields->'customfield_10134'->>'value' ILIKE '%Experimental%' THEN 'Experimental'
      ELSE NULL
    END AS release_type_group,
    csd.cycle_start_at,
    red.relevant_status_at,
    EXTRACT(EPOCH FROM (red.relevant_status_at - csd.cycle_start_at)) / 86400.0 AS cycle_time_days
  FROM jira_issues e
  JOIN cycle_start_dates csd
    ON csd.issue_key = e.issue_key
  JOIN relevant_end_dates red
    ON red.issue_key = e.issue_key
  WHERE e.issue_type = 'Epic'
    AND e.custom_fields->'customfield_10112'->>'value' = 'Yes'
    AND red.relevant_status_at IS NOT NULL
    AND csd.cycle_start_at IS NOT NULL
    AND red.relevant_status_at >= csd.cycle_start_at
    AND red.relevant_status_at >= $__timeFrom()
    AND red.relevant_status_at <= $__timeTo()
),

monthly_cycle_times AS (
  SELECT
    ect.month_start,
    ROUND(AVG(ect.cycle_time_days) FILTER (WHERE ect.release_type_group = 'Landmark')::numeric, 1)     AS landmark_avg_cycle_time_days,
    ROUND(AVG(ect.cycle_time_days) FILTER (WHERE ect.release_type_group = 'Maintenance')::numeric, 1)  AS maintenance_avg_cycle_time_days,
    ROUND(AVG(ect.cycle_time_days) FILTER (WHERE ect.release_type_group = 'Enhancement')::numeric, 1)  AS enhancement_avg_cycle_time_days,
    ROUND(AVG(ect.cycle_time_days) FILTER (WHERE ect.release_type_group = 'Experimental')::numeric, 1) AS experimental_avg_cycle_time_days
  FROM epics_with_cycle_time ect
  WHERE ect.release_type_group IS NOT NULL
    AND (
      '${exclude_project_keys:csv}' = ''
      OR ect.project_key NOT IN ($exclude_project_keys)
    )
  GROUP BY ect.month_start
)

SELECT
  to_char(m.month_start, 'YYYY-MM')          AS "Monat",
  mct.landmark_avg_cycle_time_days           AS "Landmark",
  mct.maintenance_avg_cycle_time_days        AS "Maintenance",
  mct.enhancement_avg_cycle_time_days        AS "Enhancement",
  mct.experimental_avg_cycle_time_days       AS "Experimental"
FROM months m
LEFT JOIN monthly_cycle_times mct
  ON mct.month_start = m.month_start
ORDER BY m.month_start ASC;
