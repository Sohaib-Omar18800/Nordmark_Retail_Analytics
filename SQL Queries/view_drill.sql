CREATE OR ALTER VIEW VW_drillthrough AS
SELECT 
    COALESCE(oa.ProductSKU, so.ProductSKU, pe.ProductSKU) AS ProductSKU,
    COALESCE(oa.ProductName, so.ProductName, pe.ProductName) AS ProductName,
    COALESCE(oa.ProducntCategory, so.ProductCategory, pe.ProductCategory) AS ProductCategory,
    COALESCE(oa.ProductBrand, so.ProductBrand) AS ProductBrand,
    COALESCE(so.LocationName, oa.Channel) AS LocationName,
    COALESCE(so.WeekEndDay, oa.WeekEndDay) AS WeekEndDay,
    pe.Class,
    COALESCE(so.OnHandQuantity, oa.WeeklyOnHandQuantity) AS OnHandQuantity,
    so.StockStatus,
    CASE 
        WHEN oa.OverstockStatus IS NOT NULL THEN oa.OverstockStatus
        WHEN so.LocationType = 'DC' THEN 'DC Stock'
        WHEN so.OnHandQuantity <= 0 THEN 'No OR Low Stock'
        ELSE 'Balanced & Healthy'
    END AS StockLevel,
   CASE 
        WHEN oa.ActionRequired IS NOT NULL THEN oa.ActionRequired
        WHEN so.OnHandQuantity <= 0 THEN 'Replenishment Is Needed'
        ELSE 'Normal State'
    END AS RequiredAction

FROM VW_stockout so
LEFT JOIN VW_overstock_analysis oa 
    ON so.WeekEndDay = oa.WeekEndDay 
   AND so.LocationID = oa.LocationID 
   AND so.ProductSKU = oa.ProductSKU
LEFT JOIN VW_pareto_effect pe 
    ON COALESCE(so.ProductSKU, oa.ProductSKU) = pe.ProductSKU;