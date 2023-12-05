WITH country_occurrences AS (
  SELECT country, COUNT(*) AS occurrences
  FROM Home_exchange.subscriptions
  GROUP BY country
),

unique_users AS (
  SELECT
    user_id,
    ROW_NUMBER() OVER (PARTITION BY user_id) AS row_num
  FROM Home_exchange.subscriptions
)

SELECT
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
  AND 
  (user_id IS NOT NULL AND user_id IN (
    SELECT user_id
    FROM unique_users
    WHERE row_num = 1
  ))

