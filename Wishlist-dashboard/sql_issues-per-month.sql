-- ============================================================
-- Datei:       sql_issues-per-month.sql
-- Ziel:        Anzahl neu erstellter Issues im Projekt WISH pro Monat
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-03-10
-- ============================================================

SELECT
  date_trunc('month', ji.created_at) AS month,
  COUNT(*) AS issue_count
FROM jira_issues ji
WHERE
  $__timeFilter(ji.created_at)
  AND ji.project_key = 'WISH'
GROUP BY
  1
ORDER BY
  1;