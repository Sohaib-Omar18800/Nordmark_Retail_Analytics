CREATE OR ALTER VIEW VW_pareto_effect as
WITH product_revenue AS (
    SELECT 
        sf.Sku AS ProductSKU,
        p.Product_Name AS ProductName,
        p.Category AS ProductCategory,
        SUM(sf.qty * sf.Unit_price) AS TotalRevenue
    FROM silver__sales_transactions__lite sf
    LEFT JOIN silver__product_master__lite p 
        ON sf.Sku = p.Sku
    GROUP BY sf.Sku, p.Product_Name, p.Category
),
running_revenue AS (
    SELECT 
        *,
        (select sum(TotalRevenue) from product_revenue) AS OverallRevenue,
        SUM(TotalRevenue) OVER (ORDER BY TotalRevenue DESC) AS CumulativeRevenue
    FROM product_revenue
)
SELECT 
    ProductSKU,
    ProductName,
    ProductCategory,
    TotalRevenue,
    ROUND((TotalRevenue / NULLIF(OverallRevenue, 0)) * 100, 2) AS RevenueContributionPercent,
    ROUND((CumulativeRevenue / NULLIF(OverallRevenue, 0)) * 100, 2) AS CumulativeRevenuePercent,
    
    CASE 
        WHEN (CumulativeRevenue / NULLIF(OverallRevenue, 0)) <= 0.70 THEN 'Class A (Fast Mover)'
        WHEN (CumulativeRevenue / NULLIF(OverallRevenue, 0)) <= 0.90 THEN 'Class B (Medium Mover)'
        ELSE 'Class C (Slow Mover)'
    END AS Class
FROM running_revenue;