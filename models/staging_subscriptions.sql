-- models/occurrences_by_country.sql
WITH country_occurrences AS (
  SELECT country, COUNT(*) AS occurrences
  FROM {{ source('home-exchange-407110', 'subscriptions') }}
  GROUP BY country
)
SELECT *
FROM country_occurrences
ORDER BY occurrences DESC
LIMIT 11;

-- models/non_null_records.sql
SELECT *
FROM {{ source('home-exchange-407110', 'subscriptions') }}
WHERE city IS NOT NULL OR region IS NOT NULL OR country IS NOT NULL OR department IS NOT NULL;

-- models/occurrences_by_user_id.sql
WITH user_id_occurrences AS (
  SELECT user_id, COUNT(*) AS occurrences
  FROM {{ source('home-exchange-407110', 'subscriptions') }}
  GROUP BY user_id
  HAVING COUNT(*) <= 1
)
SELECT *
FROM user_id_occurrences;
