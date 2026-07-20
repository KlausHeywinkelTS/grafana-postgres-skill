-- ============================================================
-- Datei:       sql_variable-projekt-keys.sql
-- Ziel:        Grafana-Variable: alle Projekt-Keys für Filter
-- Verwendung:  Grafana Dashboard Variable (Query-Typ)
-- Tabellen:    jira_issues, jira_issue_changelog
-- Variablen:   $__timeFilter (auf letzten Statuswechsel des Epics)
-- Erstellt:    2026-03-09
-- ============================================================

WITH epic_release_dates AS (
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
)

SELECT DISTINCT
  e.project_key
FROM jira_issues e
JOIN epic_release_dates erd ON erd.issue_key = e.issue_key
WHERE e.issue_type = 'Epic'
  AND e.project_key in ('INV', 'QUE', 'REVIN', 'LSRT', 'RM', 'CC', 'TBI', 'TPSCON', 'PL', 'GUARANTEE', 'CA', 'SEO', 'TCM', 'SW')
  AND $__timeFilter(erd.release_date)
ORDER BY e.project_key
