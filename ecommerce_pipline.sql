CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS silver;

SELECT COUNT(*) 
FROM stg.events;

-- Unique users
CREATE TABLE silver.dim_users AS
SELECT DISTINCT user_id
FROM stg.events
WHERE user_id IS NOT NULL;

-- Unique products
CREATE TABLE silver.dim_products AS
SELECT DISTINCT
    product_id,
    category_id,
    category_code,
    brand,
    price
FROM stg.events
WHERE product_id IS NOT NULL;

-- Fact table (events)
CREATE TABLE silver.fact_events AS
SELECT
    e.event_time_ts AS event_time,
    e.event_type,
    e.user_id,
    e.product_id,
    e.price,
    e.user_session,
    e.event_date
FROM stg.events e;


CREATE INDEX idx_users_userid ON silver.dim_users(user_id);
CREATE INDEX idx_products_productid ON silver.dim_products(product_id);
CREATE INDEX idx_events_userid ON silver.fact_events(user_id);
CREATE INDEX idx_events_productid ON silver.fact_events(product_id);


SELECT COUNT(*) FROM silver.dim_users;
SELECT COUNT(*) FROM silver.dim_products;
SELECT COUNT(*) FROM silver.fact_events;