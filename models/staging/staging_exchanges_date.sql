SELECT
*
FROM {{ ref('staging-exchanges-mc') }}
WHERE created_at_date BETWEEN '2021-01-01' AND '2022-11-25'