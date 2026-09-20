CREATE OR ALTER VIEW VW_stockout AS 
with stock_agg as (
select 
	cast(DATEADD(week,DATEDIFF(week,'2026-01-01',si.snapshot_date),'2026-01-01') as date) as WeekEndDay,
	si.location_id as LocationID,
	sum(si.on_hand_qty) AS OnHandQuantity,
	sl.location_type AS LocationType,
	sl.location_name As LocationName,
	si.sku as ProductSKU,
	sp.category as ProductCategory,sp.brand AS ProductBrand,sp.product_name AS ProductName
from
	silver__inventory_snapshots__lite si
left join silver__location_master__lite sl
on si.location_id = sl.location_id
left join silver__product_master__lite sp
on si.sku = sp.sku
group by si.location_id,si.sku,sl.location_name,
sl.location_type,cast(DATEADD(week,DATEDIFF(week,'2026-01-01',si.snapshot_date),'2026-01-01') as date),
sp.category,sp.brand ,sp.product_name 
)
SELECT
	WeekEndDay,LocationID,LocationType,LocationName,ProductSKU,ProductBrand,ProductCategory,ProductName,OnHandQuantity,
	CASE 
		WHEN OnHandQuantity <= 0 THEN 'Out of Stock'
		WHEN OnHandQuantity BETWEEN 1 AND 6 THEN 'Low Stock'
		ELSE 'In Stock'
	END AS StockStatus
FROM
	stock_agg 