# Prompt-Template für SQL-Generierung

Wenn der User eine neue `prompt_*.md` Datei anlegen möchte, dieses Template verwenden und am gewünschten Ort als vorausgefüllte Datei erstellen. Felder, die der User bereits angegeben hat, sofort ausfüllen. Leere Pflichtfelder mit `<!-- TODO: ausfüllen -->` markieren.

---

## Template

```markdown
# Ziel
<!-- Was soll das SQL erreichen? Beschreibe in 1-2 Sätzen. -->
<!-- TODO: ausfüllen -->

# Panel-Typ
<!-- Time Series / Table / Stat / Gauge / Bar Chart -->
<!-- TODO: ausfüllen -->

# Tabellen
<!-- Welche Tabellen werden verwendet? Oder "alle" für alle in resources/ definierten Tabellen. -->
<!-- TODO: ausfüllen -->

# Zeit-Spalte
<!-- Welche Spalte enthält den primären Timestamp? (Pflicht für Time Series) -->
<!-- TODO: ausfüllen -->

# Ausgabe-Spalten
<!-- Welche Werte sollen angezeigt werden?
     Format: Spaltenname → Alias (= Grafana-Legendenname)
     Beispiel:
       avg_temperature → "Durchschnitt Temperatur °C"
       device_id       → "Gerät"                        -->
<!-- TODO: ausfüllen -->

# Aggregation
<!-- Rohdaten ODER aggregiert?
     Bei aggregiert: Funktion angeben, z.B. AVG / SUM / COUNT / MAX
     Beispiel: "AVG pro $__interval" oder "COUNT pro Stunde" -->
Rohdaten

# Filter / Bedingungen
<!-- Zusätzliche WHERE-Bedingungen neben dem Zeitfilter.
     Beispiel:
       - Nur Gerät ${device}
       - Status = 'active'
       - location IN (${locations:raw})               -->
keine

# Grafana-Variablen
<!-- Welche Dashboard-Variablen werden eingesetzt?
     Beispiel: ${device}, ${location}, ${__interval}  -->
keine

# Referenz
<!-- Optional: Basis-SQL aus einer anderen Datei übernehmen und anpassen.
     Format: "Wie sql_<name>.sql – aber mit folgenden Änderungen:
       - <Änderung 1>
       - <Änderung 2>"                               -->
–

# Hinweise
<!-- Sonstige Anforderungen: Performance, Sortierung, Limits,
     besondere Joins, Timezone-Handling, etc.         -->
–
```
