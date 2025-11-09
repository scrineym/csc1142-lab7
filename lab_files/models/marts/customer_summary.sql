{{ config(materialized='table') }}

-- Customer analytics: Order patterns
SELECT 
    customer_id,
    company_name,
    country,
    COUNT(DISTINCT order_id) as total_orders,
    ROUND(SUM(freight_cost), 2) as total_freight,
    ROUND(AVG(freight_cost), 2) as avg_freight,
    MIN(order_date) as first_order_date,
    MAX(order_date) as last_order_date
FROM {{ ref('fct_orders') }}
GROUP BY customer_id, company_name, country