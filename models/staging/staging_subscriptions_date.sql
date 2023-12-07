SELECT
*
FROM {{ ref('staging_subscriptions') }}
WHERE subscription_date_ BETWEEN '2021-01-01' AND '2021-10-31'