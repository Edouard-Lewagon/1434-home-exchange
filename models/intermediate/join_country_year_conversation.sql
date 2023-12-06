SELECT DISTINCT
    e.conversation_id
    ,e.exchange_id
    ,e.created_at_date
    ,e.creator_id
    ,e.guest_user_id
    ,e.host_user_id
    ,e.finalized_at_date
    ,e.canceled_at_date
    ,e.start_on_date
    ,e.end_on_date
    ,e.guest_countguest_count
    ,e.night_count
    ,e.user_cancellation_id
    ,e.exchange_type
    ,e.home_type
    ,e.residence_type
    ,e.capacity
    ,e.country
    ,s.country AS host_country
    ,su.country AS guest_country
    ,EXTRACT(YEAR FROM created_at_date) AS year_conversation
    ,CONCAT(SUBSTR(CAST(created_at_date AS STRING), 1, 4), '_', CAST(e.host_user_id AS STRING)) AS annee_host_id
    ,CONCAT(SUBSTR(CAST(created_at_date AS STRING), 1, 4), '_', CAST(e.guest_user_id AS STRING)) AS annee_guest_id

FROM {{ ref('staging_exchanges_date') }} e
LEFT JOIN {{ ref('staging_subscriptions_date') }} s ON e.host_user_id=s.user_id
LEFT JOIN {{ ref('staging_subscriptions_date') }} su ON e.guest_user_id=su.user_id