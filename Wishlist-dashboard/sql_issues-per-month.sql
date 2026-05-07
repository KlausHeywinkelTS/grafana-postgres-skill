-- ============================================================
-- Datei:       sql_issues-per-month.sql
-- Ziel:        Anzahl neu erstellter Issues im Projekt WISH pro Monat
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter, ${source} (Multi-Value, description-Filter)
-- Basis-SQL:   –
-- Erstellt:    2026-04-23
-- ============================================================

SELECT
  date_trunc('month', ji.created_at) AS month,
  COUNT(*) AS issue_count
FROM jira_issues ji
WHERE
  $__timeFilter(ji.created_at)
  AND ji.project_key = 'WISH'
  AND (
        ji.description ~* '${source:pipe}'
        OR (
          '${source:pipe}' ~* 'Customer Voice Uncensored'
          AND ji.description ILIKE '%teams message%'
        )
      )
GROUP BY
  1
ORDER BY
  1;