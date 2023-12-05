WITH country_occurrences AS (
  SELECT country, COUNT(*) AS occurrences
  FROM Home_exchange.subscriptions
  GROUP BY country
)
SELECT DISTINCT
CONCAT(SUBSTR(CAST(subscription_date AS STRING), 1, 4), '_', CAST(user_id AS STRING)) AS annee_user_id,
CAST(subscription_date AS DATE) AS subscription_date_,
user_id,
renew,
CAST(first_subscription_date AS DATE) AS first_subscription_date_,
first_subscription,
referral,
promotion,
payment3x,
payment2,
payment3,
country,
FROM Home_exchange.subscriptions
WHERE
  (country IS NOT NULL AND country IN (
    SELECT country
    FROM country_occurrences
    ORDER BY occurrences DESC
    LIMIT 11
  ))

