{{ config(materialized='table') }}

WITH s AS (
  SELECT
    user_session,
    MIN(event_time) AS session_start,
    MAX(event_time) AS session_end,
    COUNT(*) AS events_in_session,
    COUNT(*) FILTER (WHERE event_type='view')     AS views,
    COUNT(*) FILTER (WHERE event_type='cart')     AS carts,
    COUNT(*) FILTER (WHERE event_type='purchase') AS purchases,
    SUM(price) FILTER (WHERE event_type='purchase')::numeric AS revenue
  FROM {{ source('silver','fact_events') }}
  GROUP BY user_session
)
SELECT
  user_session,
  session_start,
  session_end,
  EXTRACT(EPOCH FROM (session_end - session_start))/60.0 AS session_duration_minutes,
  events_in_session, views, carts, purchases, revenue
FROM s
ORDER BY session_start