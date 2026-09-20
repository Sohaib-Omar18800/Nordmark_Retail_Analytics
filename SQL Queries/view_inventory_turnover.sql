CREATE OR ALTER VIEW VW_inventory_turnover AS

WITH sales_type as (
select 
	CAST(DATEADD(WEEK,DATEDIFF(WEEK,'2026-01-01',transaction_date),'2026-01-01') AS DATE) WeekEndDay,
	sl.location_type as LocationType,
	sp.category as ProductCategory,
	SUM(qty) as WeeklyTotalQuantityByLocationType
from 
	silver__sales_transactions__lite st 
left join 
	silver__product_master__lite sp
on
	st.sku = sp.sku
left join silver__location_master__lite sl
on st.location_id = sl.location_id
Group By 
	CAST(DATEADD(WEEK,DATEDIFF(WEEK,'2026-01-01',transaction_date),'2026-01-01') AS DATE),
	sl.location_type,
	category
	),
snap_inv as (
	select 
			CAST(DATEADD(WEEK,DATEDIFF(WEEK,'2026-01-01',snapshot_date),'2026-01-01') AS DATE) WeekEndDay,
			AVG(on_hand_qty) AverageOnHandQuantity,
			sp.category as ProductCategory,
			sl.location_type as LocationType
	from
		silver__inventory_snapshots__lite si
	left join 
		silver__product_master__lite sp
	on si.sku = sp.sku
	left join silver__location_master__lite sl
	on sl.location_id = si.location_id
	Group By
		sp.category, sl.location_type,CAST(DATEADD(WEEK,DATEDIFF(WEEK,'2026-01-01',snapshot_date),'2026-01-01') AS DATE)
)
SELECT 
	st.WeekEndDay,
	st.LocationType,
	st.ProductCategory,
	WeeklyTotalQuantityByLocationType,
	AverageOnHandQuantity,
	ROUND(
      CAST(COALESCE(WeeklyTotalQuantityByLocationType,0) AS FLOAT)/ 
        NULLIF(AverageOnHandQuantity, 0), 
    2) AS InventoryTurnoverRate
from
	sales_type st
left join 
	snap_inv si
on st.WeekEndDay = si.WeekEndDay and st.LocationType = si.LocationType and st.ProductCategory = si.ProductCategory