-- ============================================================
-- Datei:       sql_landmark-epics-ohne-p2m-nach-projekt.sql
-- Ziel:        Verteilung Landmark-Epics ohne P2M-Tasks nach Projekt
-- Panel-Typ:   Pie Chart (Donut)
-- Tabellen:    jira_issues, jira_issue_changelog
-- Variablen:   $__timeFilter (auf letzten Statuswechsel des Epics)
--              ${exclude_project_keys} (Multi-Value, optional: Projekte ausschließen)
-- Basis-SQL:   sql_landmark-epics-p2m-uebersicht.sql
-- Erstellt:    2026-03-09
-- ============================================================

WITH epic_release_dates AS (
  -- Letztes relevantes Status-Datum pro Epic:
  -- Prio 1: letzter Wechsel nach 'After Release'
  -- Prio 2: letzter Wechsel nach 'Done' oder 'Closed'
  SELECT
    issue_key,
    COALESCE(
      MAX(CASE WHEN to_value = 'After Release' THEN created_at END),
      MAX(CASE WHEN to_value IN ('Done', 'Closed') THEN created_at END)
    ) AS release_date
  FROM jira_issue_changelog
  WHERE field_name = 'status'
    AND to_value IN ('After Release', 'Done', 'Closed')
  GROUP BY issue_key
),

landmark_epics_ohne_p2m AS (
  SELECT
    e.project_key,
    erd.release_date
  FROM jira_issues e
  JOIN epic_release_dates erd ON erd.issue_key = e.issue_key
  WHERE e.issue_type = 'Epic'
    AND e.custom_fields->'customfield_10112'->>'value' = 'Yes'
    AND e.custom_fields->'customfield_10134'->>'value' ILIKE '%Landmark Update%'
    AND (
      '${exclude_project_keys:csv}' = ''
      OR e.project_key NOT IN ($exclude_project_keys)
    )
    AND NOT EXISTS (
      SELECT 1
      FROM jira_issues child
      WHERE child.parent_key = e.issue_key
        AND child.issue_type = 'P2M Task'
    )
)

SELECT
  project_key      AS "Project",
  COUNT(*)         AS "Number of Epics"
FROM landmark_epics_ohne_p2m
WHERE $__timeFilter(release_date)
GROUP BY project_key
ORDER BY COUNT(*) DESC
