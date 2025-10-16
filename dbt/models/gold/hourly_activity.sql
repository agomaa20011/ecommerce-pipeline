{{ config(materialized='table') }}

SELECT
  date_trunc('hour', event_time) AS event_hour,
  COUNT(*) AS events,
  COUNT(*) FILTER (WHERE event_type='view')     AS views,
  COUNT(*) FILTER (WHERE event_type='cart')     AS carts,
  COUNT(*) FILTER (WHERE event_type='purchase') AS purchases
FROM {{ source('silver','fact_events') }}
GROUP BY 1
ORDER BY 1