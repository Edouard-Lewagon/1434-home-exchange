SELECT DISTINCT

    conversation_id
    ,exchange_id
    ,created_at_date
    ,creator_id
    ,guest_user_id
    ,host_user_id
    ,finalized_at_date
    ,canceled_at_date
    ,start_on_date
    ,end_on_date
    ,guest_countguest_count
    ,night_count
    ,user_cancellation_id
    ,exchange_type
    ,home_type
    ,residence_type
    ,capacity
    ,host_country
    ,guest_country
    ,year_conversation
    ,annee_host_id
    ,annee_guest_id
    ,CASE
      WHEN j.annee_host_id = s.annee_user_id THEN CAST(s.renew AS STRING) 
      WHEN j.annee_guest_id = su.annee_user_id THEN CAST(su.renew AS STRING) 
    END AS renew_statut

FROM {{ ref('join_country_year_conversation') }} j
LEFT JOIN {{ ref('staging_subscriptions') }} s ON j.host_user_id=s.user_id
LEFT JOIN {{ ref('staging_subscriptions') }} su ON j.guest_user_id=su.user_id