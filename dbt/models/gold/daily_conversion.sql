{{ config(materialized='table') }}

WITH daily AS (
  SELECT
    date_trunc('day', event_time)::date AS event_date,
    COUNT(*) FILTER (WHERE event_type='view')     AS views,
    COUNT(*) FILTER (WHERE event_type='cart')     AS carts,
    COUNT(*) FILTER (WHERE event_type='purchase') AS purchases
  FROM {{ source('silver','fact_events') }}
  GROUP BY 1
)
SELECT
  event_date, views, carts, purchases,
  CASE WHEN views > 0 THEN purchases::numeric/views ELSE 0 END AS conversion_rate
FROM daily
ORDER BY event_date