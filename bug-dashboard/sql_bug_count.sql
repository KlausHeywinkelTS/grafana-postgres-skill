-- ============================================================
-- Datei:       sql_bug_count.sql
-- Ziel:        Anzahl der im gewählten Zeitraum erstellten offenen
--              Bug-Issues in den Product-Team-Projekten anzeigen.
--              Offen = Status nicht Done/Closed/Rejected.
-- Panel-Typ:   Stat
-- Tabellen:    jira_issues
-- Variablen:   ${project:sqlstring}, $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-08-03
-- ============================================================

SELECT
  COUNT(*) AS "Anzahl Bugs"
FROM jira_issues AS i
WHERE i.issue_type = 'Bug'
  AND (
    i.status IS NULL
    OR i.status NOT IN ('Done', 'Closed', 'Rejected')
  )
  AND i.project_key IN (
    'INV', 'QUE', 'REVIN', 'RM', 'CC', 'LSRT', 'PL',
    'TBI', 'TPSCON', 'GUARANTEE', 'SEO', 'CA', 'TCM'
  )
  AND i.project_key IN (${project:sqlstring})
  AND $__timeFilter(i.created_at);
