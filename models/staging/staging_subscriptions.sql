WITH country_occurrences AS (
  SELECT country, COUNT(*) AS occurrences
  FROM Home_exchange.subscriptions
  GROUP BY country
)
<<<<<<< HEAD
SELECT DISTINCT
CONCAT(SUBSTR(CAST(subscription_date AS STRING), 1, 4), '_', CAST(user_id AS STRING)) AS annee_user_id,
CAST(subscription_date AS DATE) AS subscription_date_,
=======


SELECT DISTINCT
CONCAT(SUBSTR(CAST(subscription_date AS STRING), 1, 4), '_', CAST(user_id AS STRING)) AS annee_user_id,
CAST(subscription_date AS DATE) AS subscription_date,
>>>>>>> c3eb1d8b1be48171b91259974fb3c5c268a3200a
user_id,
renew,
CAST(first_subscription_date AS DATE) AS first_subscription_date,
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
<<<<<<< HEAD

=======
  
>>>>>>> c3eb1d8b1be48171b91259974fb3c5c268a3200a
