-- ============================================================
-- Datei:       sql_distribution_of_bugs_per_team.sql
-- Ziel:        Verteilung der offenen Bug-Issues nach Team anzeigen;
--              Team = Jira project_key; Anzahl Bugs je Team.
--              Offen = Status nicht Done/Closed/Rejected.
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   ${project:sqlstring}, $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-08-05
-- ============================================================

WITH filtered_bugs AS (
  SELECT
    i.project_key,
    i.created_at
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
    AND (
      'All' IN (${project:sqlstring})
      OR i.project_key IN (${project:sqlstring})
    )
)
SELECT
  b.project_key AS "Team",
  COUNT(*) AS "Anzahl Bugs"
FROM filtered_bugs AS b
WHERE $__timeFilter(b.created_at)
GROUP BY b.project_key
ORDER BY b.project_key;
