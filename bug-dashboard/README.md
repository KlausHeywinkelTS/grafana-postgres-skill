# Dashboard: Bug Dashboard

## Zweck

Für alle Product Teams soll es ein Dashboard geben, welches einen Überblick über die Bug-Issues in jira dieser Teams gibt. Bug issues sind issues mit dem issuetype "Bug".

Es geht um die Jira SPaces mit diesen Keys:

- INV
- QUE
- REVIN
- RM
- CC
- LSRT
- PL
- TBI
- TPSCON
- GUARANTEE
- SEO
- CA
- TCM

## Zielgruppe

- Product Manager
- Group Product Manager
- 1st und 2nd level support
- Product Management Leadership

## Datenquellen

- jira_issues
- jira_issue_changelog

## Dashboard-Variablen (Grafana)

${project}: Projekt-Filter, Werte aus jira_issues.project_key. "All" ist möglich.

## Zeitraum

Wird über den STandard Date-Range Filter der Grafana-Dashboards gesetzt

## Panels

### Panel: [Bug-Count]

- **Typ**: Stat
- **Beschreibung**: Number of open bugs matching the filter (not in Done category: Done, Closed, Rejected)
- **Metriken / Spalten**: count
- **Filter**: project; date-range; status category is not Done
- **Aggregation**: none
- **Hinweise**: none

### Panel: [Age of bugs]

- **Typ**: Bar Chart
- **Beschreibung**: shows the number of bugs that are not in the `Done` status category, grouped by age (age = now - created-date). The `Done` category contains the statuses `Done`, `Closed`, and `Rejected`. Age-groups: <=30days; >30 and <= 60; > 60 and <=90; > 90 and <= 365; > 365 and < 730; >= 730
- **Metriken / Spalten**: count per age-group
- **Filter**: project; date-range (created_at); status category is not `Done` (statuses `Done`, `Closed`, `Rejected`)
- **Aggregation**: sum of bugs
- **Hinweise**: none

### Panel: [bug lead time]

- **Typ**: Stat
- **Beschreibung**: average lead time for all bugs (lead time = duration from created until closed)
- **Metriken / Spalten**: average lead time
- **Filter**: project; date-range
- **Aggregation**: none

### Panel: [distribution of bug priority]

- **Typ**: bar chart
- **Beschreibung**: for each priority group: Count how many open bugs match (not in Done category: Done, Closed, Rejected). Groups left-to-right: Showstopper; High = High/Major/High Standard; Medium = Medium/Normal; Low = Low/Trivial/Minor; None; other priorities unchanged
- **Metriken / Spalten**: Priorities/Bug Count
- **Filter**: project; time-filter; status category is not Done
- **Aggregation**: count
- **Hinweise**: none

### Panel: [distribution of bugs per team]

- **Typ**: Bar Chart
- **Beschreibung**: shows per team the number of open bugs. Team means: Key of the Jira project.
- **Metriken / Spalten**: Jira project-key/bug count
- **Filter**: project; time-filter; only open bugs
- **Aggregation**: count
- **Hinweise**: none

### Panel: [example-name]

- **Typ**: <!-- Time Series / Table / Stat / Gauge / Bar Chart -->
- **Beschreibung**: <!-- Was zeigt dieses Panel? -->
- **Metriken / Spalten**: <!-- -->
- **Filter**: <!-- -->
- **Aggregation**: <!-- -->
- **Hinweise**: <!-- -->

<!-- Weitere Panels nach gleichem Muster ergänzen -->

## Offene Fragen / TODOs
