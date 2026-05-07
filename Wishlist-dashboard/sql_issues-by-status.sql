-- ============================================================
-- Datei:       sql_issues-by-status.sql
-- Ziel:        Anzahl der Issues im Projekt WISH gruppiert nach Status
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter, ${source} (Multi-Value, description-Filter)
-- Basis-SQL:   –
-- Erstellt:    2026-04-23
-- ============================================================

WITH all_statuses AS (
    SELECT DISTINCT status
    FROM jira_issues
    WHERE project_key = 'WISH'
)

SELECT
    s.status,
    COUNT(ji.id) AS issue_count
FROM
    all_statuses s
LEFT JOIN jira_issues ji
    ON ji.status = s.status
    AND $__timeFilter(ji.created_at)
WHERE ji.project_key = 'WISH'
  AND (
    ji.description ~* '${source:pipe}'
    OR (
      '${source:pipe}' ~* 'Customer Voice Uncensored'
      AND ji.description ILIKE '%teams message%'
    )
  )
GROUP BY
    s.status
ORDER BY
    s.status;
