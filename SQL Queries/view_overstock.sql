CREATE OR ALTER VIEW VW_overstock_analysis AS
with sales_cte as (
select 
	CAST(DATEADD(week,DATEDIFF(week,'2026-01-01',transaction_date),'2026-01-01') AS DATE) as WeekEndDay,
	st.location_id as LocationID,
	st.channel as Channel,
	st.sku as ProductSKU,
	sp.brand as ProductBrand,
	sp.category as ProducntCategory,
	sp.product_name as ProductName,
	sum(st.qty) as WeekSalesQuantity
from 
	silver__sales_transactions__lite st
left join 
	silver__product_master__lite sp
on 
	sp.sku = st.sku
group by 
	CAST(DATEADD(week,DATEDIFF(week,'2026-01-01',transaction_date),'2026-01-01') AS DATE),
	st.location_id,st.channel,st.sku,sp.brand,sp.category,sp.product_name
),
snap_inv as (
SELECT 
	CAST(DATEADD(week,DATEDIFF(week,'2026-01-01',snapshot_date),'2026-01-01') AS DATE) as WeekEndDay,
	location_id as LocationID,
	sku AS ProductSKU,
	on_hand_qty as WeeklyOnHandQuantity,
	ROW_NUMBER() OVER(PARTITION BY CAST(DATEADD(week,DATEDIFF(week,'2026-01-01',snapshot_date),'2026-01-01') AS DATE),
	location_id,sku order by snapshot_date desc) as rnk
from 
	silver__inventory_snapshots__lite si


),
weekly_snap as (
select * from snap_inv where rnk = 1
),
dc_movement as(
select
	CAST(DATEADD(week,DATEDIFF(week,'2026-01-01',movement_date),'2026-01-01') AS DATE) as WeekEndDay,
	movement_type AS MovementType,
	sku AS ProductSKU,
	to_location_id AS ToLocationID,
	sum(qty) as TotalReplenish
from 
	silver__inventory_movements__lite
where from_location_id like 'DC%'
group by movement_type,sku,to_location_id,
CAST(DATEADD(week,DATEDIFF(week,'2026-01-01',movement_date),'2026-01-01') AS DATE)
),
joined_table as (
select 
	sc.WeekEndDay,
	sc.LocationID,
	sc.Channel,
	sc.ProductSKU,
	sc.ProducntCategory,
	sc.ProductBrand,
	sc.ProductName,
	sc.WeekSalesQuantity,
	si.WeeklyOnHandQuantity,
	dm.TotalReplenish,
	ROUND(CAST(COALESCE(si.WeeklyOnHandQuantity,0) AS FLOAT) / 
	CASE 
		WHEN sc.WeekSalesQuantity is null or sc.WeekSalesQuantity = 0 THEN 1 
		else sc.WeekSalesQuantity 
	end
	,2) as WeekSupply
from 
sales_cte sc
left join weekly_snap si
on sc.LocationID = si.LocationID and sc.WeekEndDay = si.WeekEndDay and sc.ProductSKU = si.ProductSKU
left join dc_movement as dm
on sc.WeekEndDay=dm.WeekEndDay and sc.LocationID = dm.ToLocationID and sc.ProductSKU = dm.ProductSKU
)
select 
	*,
	CASE 
	WHEN WeeklyOnHandQuantity <= 0 THEN 'No OR Low Stock'
	WHEN WeekSupply > 8 THEN 'Severe Overstock'
	WHEN WeekSupply BETWEEN 4 AND 8 THEN 'Overstock'
	ELSE 'Balanced & Healthy'
END AS OverstockStatus,
CASE 
        WHEN WeekSupply >= 4 AND TotalReplenish > 0 
            THEN 'Stop DC Transfer'
        WHEN WeeklyOnHandQuantity <= 0 AND TotalReplenish = 0 
            THEN 'Replenishment Is Needed'
        ELSE 'Normal State'
    END AS ActionRequired

from
	joined_table