SELECT
    o.OrderID as order_id,
    o.OrderDate as order_date,
    o.CustomerID as customer_id,
    c.company_name,
    c.country,
    o.Freight as freight_cost
FROM {{ source('northwind', 'Orders') }} o
LEFT JOIN {{ ref('stg_customers') }} c
    ON o.CustomerID = c.customer_id
