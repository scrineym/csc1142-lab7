SELECT
    CustomerID,
    CompanyName,
    Country
FROM {{ source('northwind', 'Customers') }}
WHERE Country = 'USA'