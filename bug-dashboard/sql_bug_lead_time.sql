-- ============================================================
-- Datei:       sql_bug_lead_time.sql
-- Ziel:        Durchschnittliche Lead Time geschlossener Bug-Issues
--              vom Erstellungs- bis zum Auflösungszeitpunkt anzeigen.
-- Panel-Typ:   Stat
-- Tabellen:    jira_issues
-- Variablen:   ${project:sqlstring}, $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-08-03
-- ============================================================

SELECT
  ROUND(
    AVG(EXTRACT(EPOCH FROM (i.resolution_date - i.created_at)) / 86400.0),
    2
  ) AS "Durchschnittliche Bug Lead Time (Tage)"
FROM jira_issues AS i
WHERE i.issue_type = 'Bug'
  AND i.status IN ('Done', 'Closed')
  AND i.created_at IS NOT NULL
  AND i.resolution_date IS NOT NULL
  AND i.project_key IN (
    'INV', 'QUE', 'REVIN', 'RM', 'CC', 'LSRT', 'PL',
    'TBI', 'TPSCON', 'GUARANTEE', 'SEO', 'CA', 'TCM'
  )
  AND (
    'All' IN (${project:sqlstring})
    OR i.project_key IN (${project:sqlstring})
  )
  AND $__timeFilter(i.resolution_date);
