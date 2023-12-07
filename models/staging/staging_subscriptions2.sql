SELECT
    DISTINCT annee_user_id,
    subscription_date,
    user_id,
    CASE
        WHEN subscription_date = first_subscription_date THEN 0
        ELSE renew
    END as renew,
    first_subscription_date,
    first_subscription,
    referral,
    promotion,
    payment3x,
    payment2,
    payment3,
    country2
FROM {{ ref('staging_subscriptions') }}


