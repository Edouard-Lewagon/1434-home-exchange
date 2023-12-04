-- models/occurrences_by_country.sql
WITH country_occurrences AS (
  SELECT
    c.country,
    COUNT(*) AS occurrences
  FROM {{ source('home-exchange-407110', 'subscriptions') }} AS c
  WHERE c.city IS NOT NULL OR c.region IS NOT NULL OR c.country IS NOT NULL OR c.department IS NOT NULL
  GROUP BY c.country
)

SELECT
  s.*,
  co.occurrences
FROM {{ source('home-exchange-407110', 'subscriptions') }} AS s
LEFT JOIN country_occurrences AS co
ON s.country = co.country
ORDER BY co.occurrences DESC
LIMIT 11;
