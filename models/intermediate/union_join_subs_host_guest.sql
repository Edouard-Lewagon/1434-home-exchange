SELECT *, 'guest' AS user_type
FROM {{ ref('staging-exchanges-mc') }} e
INNER JOIN {{ ref('staging_subscriptions') }} s
ON e.guest_user_id = s.user_id

UNION ALL

SELECT *, 'host' AS user_type
FROM {{ ref('staging-exchanges-mc') }} e
INNER JOIN {{ ref('staging_subscriptions') }} s
ON e.host_user_id = s.user_id
