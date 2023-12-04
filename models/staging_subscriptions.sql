-- models/occurrences_by_country.sql
WITH country_occurrences AS (
  SELECT country, COUNT(*) AS occurrences
  FROM Home_exchange.subscriptions
  GROUP BY country
)
SELECT *
FROM country_occurrences
ORDER BY occurrences DESC
LIMIT 11;
