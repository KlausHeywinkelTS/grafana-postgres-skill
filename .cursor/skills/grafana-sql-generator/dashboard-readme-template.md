# Dashboard-README Template

Wenn ein neuer Dashboard-Ordner angelegt wird, dieses Template als `README.md` in den Ordner schreiben.

---

## Template

```markdown
# Dashboard: <Name des Dashboards>

## Zweck
<!-- Wofür ist dieses Dashboard? Wer nutzt es? Was soll auf einen Blick erkennbar sein? -->
<!-- TODO: ausfüllen -->

## Zielgruppe
<!-- z.B. Entwicklungsteam, Management, Projektleiter -->
<!-- TODO: ausfüllen -->

## Datenquellen
<!-- Welche Tabellen werden primär verwendet? -->
- jira_issues
- jira_issue_changelog

## Dashboard-Variablen (Grafana)
<!-- Variablen, die im Dashboard global verfügbar sind und in SQLs verwendet werden sollen.
     Format:
       - ${var_name}: Beschreibung, mögliche Werte / Query
     Beispiel:
       - ${project}: Projekt-Filter, Werte aus jira_issues.project_key
       - ${issue_type}: Issue-Typ-Filter, z.B. Story / Bug / Task           -->
<!-- TODO: ausfüllen oder "keine" -->

## Zeitraum
<!-- Typischer Standardzeitraum des Dashboards, z.B. "Letzte 30 Tage", "Aktueller Sprint" -->
<!-- TODO: ausfüllen -->

## Panels

<!-- Pro Panel einen Abschnitt. Der Skill liest diese Liste und generiert daraus Prompt-Grundgerüste. -->
<!-- Mindestangaben pro Panel: Name, Typ, Beschreibung. Rest ist optional aber hilfreich. -->

### Panel: <Panel-Name>
- **Typ**: <!-- Time Series / Table / Stat / Gauge / Bar Chart -->
- **Beschreibung**: <!-- Was zeigt dieses Panel? Welche Frage beantwortet es? -->
- **Metriken / Spalten**: <!-- Welche Werte sollen angezeigt werden? -->
- **Filter**: <!-- Einschränkungen über die Dashboard-Variablen hinaus -->
- **Aggregation**: <!-- Rohdaten / AVG / COUNT / SUM pro Zeitintervall -->
- **Hinweise**: <!-- Besonderheiten, z.B. "nur offene Issues", "gruppiert nach Status" -->

### Panel: <Panel-Name>
- **Typ**: <!-- Time Series / Table / Stat / Gauge / Bar Chart -->
- **Beschreibung**: <!-- Was zeigt dieses Panel? -->
- **Metriken / Spalten**: <!-- -->
- **Filter**: <!-- -->
- **Aggregation**: <!-- -->
- **Hinweise**: <!-- -->

<!-- Weitere Panels nach gleichem Muster ergänzen -->

## Offene Fragen / TODOs
<!-- Ungeklärte Punkte zum Dashboard, die noch besprochen werden müssen -->
<!-- TODO: ausfüllen oder entfernen -->
```

---

## Hinweise zum Ausfüllen

### Panel-Typen und typische Verwendung

| Typ | Wann verwenden |
|-----|----------------|
| **Time Series** | Verlauf über Zeit (Trends, Entwicklung) |
| **Stat** | Einzelne Kennzahl (Anzahl, Summe, Durchschnitt) |
| **Gauge** | Einzelwert mit Zielbereich (z.B. Fortschritt in %) |
| **Bar Chart** | Vergleich zwischen Kategorien (z.B. Issues pro Status) |
| **Table** | Detailliste mit mehreren Spalten |

### Tipps für gute Panel-Beschreibungen

- **Konkret**: "Zeigt die Anzahl neu erstellter Issues pro Tag" statt "Issue-Verlauf"
- **Frage formulieren**: "Wie viele Issues wurden im Zeitraum abgeschlossen?"
- **Gruppierung nennen**: "Gruppiert nach Status / Assignee / Issue-Typ"
- **Scope eingrenzen**: "Nur Stories und Bugs, keine Epics"
