WITH country_occurrences AS (
  SELECT country, COUNT(*) AS occurrences
  FROM {{ source('home-exchange-407110', 'exchanges') }}
  GROUP BY country
)
SELECT
    conversation_id,
    exchange_id,
    CAST(created_at AS DATE) AS created_at_date,
    creator_id,
    guest_user_id,
    host_user_id,
    CAST(finalized_at AS DATE) AS finalized_at_date,
    CAST(canceled_at AS DATE) AS canceled_at_date,
    CAST(start_on AS DATE) AS start_on_date,
    CAST(end_on AS DATE) AS end_on_date,
    guest_countguest_count,
    night_count,
    user_cancellation_id,
    exchange_type,
    home_type,
    residence_type,
    capacity,
    country,
from {{ source('home-exchange-407110', 'exchanges') }}
WHERE
  (country IS NOT NULL AND country IN (
    SELECT country
    FROM country_occurrences
    ORDER BY occurrences DESC
    LIMIT 10
  ))