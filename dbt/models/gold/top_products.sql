{{ config(materialized='table') }}

WITH agg AS (
  SELECT
    product_id,
    COUNT(*) FILTER (WHERE event_type='view')     AS views,
    COUNT(*) FILTER (WHERE event_type='cart')     AS carts,
    COUNT(*) FILTER (WHERE event_type='purchase') AS purchases,
    SUM(price) FILTER (WHERE event_type='purchase')::numeric AS revenue
  FROM {{ source('silver','fact_events') }}
  GROUP BY product_id
)
SELECT
  p.product_id,
  p.category_code,
  p.brand,
  a.views, a.carts, a.purchases, a.revenue
FROM agg a
LEFT JOIN {{ source('silver','dim_products') }} p USING (product_id)
ORDER BY a.revenue DESC NULLS LAST, a.purchases DESC NULLS LAST
LIMIT 100