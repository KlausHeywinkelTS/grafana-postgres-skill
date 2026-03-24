-- ============================================================
-- Datei:       sql_issues-by-status.sql
-- Ziel:        Anzahl der Issues im Projekt WISH gruppiert nach Status
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-03-10
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
GROUP BY
    s.status
ORDER BY
    s.status;
