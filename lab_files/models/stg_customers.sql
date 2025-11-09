SELECT
    CustomerID as customer_id,
    CompanyName as company_name,
    ContactName as contact_name,
    Country as country,
    City as city
FROM {{ source('northwind', 'Customers') }}
WHERE CustomerID IS NOT NULL
