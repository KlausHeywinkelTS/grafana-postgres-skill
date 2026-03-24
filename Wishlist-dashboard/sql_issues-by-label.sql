-- ============================================================
-- Datei:       sql_issues-by-label.sql
-- Ziel:        Anzahl der Issues im Projekt WISH gruppiert nach Label
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-03-10
-- ============================================================

SELECT
  lbl AS label,
  COUNT(*) AS issue_count
FROM jira_issues ji
CROSS JOIN LATERAL unnest(
  string_to_array(
    trim(both '{}' from COALESCE(ji.labels, '')),
    ','
  )
) AS lbl
WHERE
  $__timeFilter(ji.created_at)
  AND ji.project_key = 'WISH'
  AND COALESCE(ji.labels, '') <> ''
GROUP BY
  lbl
ORDER BY
  issue_count DESC, label;
