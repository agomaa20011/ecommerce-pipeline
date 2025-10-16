with events as (
  select
    date_trunc('day', fe.event_time) as event_date,
    coalesce(p.category_code, 'unknown') as category_code,
    fe.event_type,
    fe.price
  from {{ source('silver', 'fact_events') }} fe
  left join {{ source('silver', 'dim_products') }} p
    on p.product_id = fe.product_id
  where fe.event_type in ('view','cart','purchase')
),

agg as (
  select
    event_date,
    category_code,
    count(*) filter (where event_type = 'view')     as views,
    count(*) filter (where event_type = 'cart')     as carts,
    count(*) filter (where event_type = 'purchase') as purchases,
    sum(case when event_type = 'purchase' then price else 0 end) as revenue
  from events
  group by 1,2
)

select *
from agg
order by 1,2