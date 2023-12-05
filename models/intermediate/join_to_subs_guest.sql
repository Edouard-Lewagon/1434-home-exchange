SELECT *
FROM {{ ref('staging-exchanges-mc') }} e
INNER JOIN {{ ref('staging_subscriptions') }} s
ON e.guest_user_id = s.user_id
