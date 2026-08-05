-- ============================================================
-- Datei:       sql_age_of_bugs.sql
-- Ziel:        Anzahl der Bug-Issues je Altersgruppe anzeigen;
--              ohne Bugs der Statuskategorie Done.
--              Done-Status: Done, Closed, Rejected.
--              Zeitfilter auf created_at (Grafana Date Range).
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   ${project:sqlstring}, $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-08-03
-- ============================================================

WITH age_groups (sort_order, age_group) AS (
  VALUES
    (1, '<= 30 Tage'),
    (2, '> 30 und <= 60 Tage'),
    (3, '> 60 und <= 90 Tage'),
    (4, '> 90 und <= 365 Tage'),
    (5, '> 365 und < 730 Tage'),
    (6, '>= 730 Tage')
),
filtered_bugs AS (
  SELECT
    i.created_at,
    CASE
      WHEN CURRENT_TIMESTAMP - i.created_at <= INTERVAL '30 days'
        THEN '<= 30 Tage'
      WHEN CURRENT_TIMESTAMP - i.created_at <= INTERVAL '60 days'
        THEN '> 30 und <= 60 Tage'
      WHEN CURRENT_TIMESTAMP - i.created_at <= INTERVAL '90 days'
        THEN '> 60 und <= 90 Tage'
      WHEN CURRENT_TIMESTAMP - i.created_at <= INTERVAL '365 days'
        THEN '> 90 und <= 365 Tage'
      WHEN CURRENT_TIMESTAMP - i.created_at < INTERVAL '730 days'
        THEN '> 365 und < 730 Tage'
      ELSE '>= 730 Tage'
    END AS age_group
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
  g.age_group AS "Altersgruppe",
  COUNT(b.age_group) AS "Number of Bugs"
FROM age_groups AS g
LEFT JOIN filtered_bugs AS b
  ON b.age_group = g.age_group
 AND $__timeFilter(b.created_at)
GROUP BY
  g.sort_order,
  g.age_group
ORDER BY g.sort_order;
