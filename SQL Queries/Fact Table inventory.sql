WITH week_day AS (
    SELECT 
        CAST(DATEADD(WEEK,DATEDIFF(week,0,snapshot_date),-1) AS DATE) AS WeekStartDate,
        sku ,
        location_id ,
        on_hand_qty ,
        ROW_NUMBER() OVER (
				PARTITION BY CAST(DATEADD(WEEK,DATEDIFF(week,0,snapshot_date),-1) AS DATE), 
                location_id, 
                sku 
				ORDER BY snapshot_date DESC
        ) AS ranked
    FROM silver__inventory_snapshots__lite
),
snapshot_cte as (
SELECT 
	WeekStartDate,location_id as LocationID,sku as ProductSKU,on_hand_qty as OnHandQuantity
FROM week_day
WHERE ranked = 1
),
--============================================
mv_wd as(
SELECT 
CAST(DATEADD(WEEK,DATEDIFF(week,0,movement_date),-1) AS DATE) AS WeekStartDate,
COALESCE(from_location_id, to_location_id) as LocationID,
sku as ProductSKU,
SUM(case when movement_type = 'SALE' THEN ABS(qty) end) as WeeklySalesQty,
SUM(CASE WHEN movement_type = 'REPLENISH' THEN ABS(qty) WHEN movement_type = 'SALE' THEN -ABS(qty) ELSE qty END) as NetMovementQty
from silver__inventory_movements__lite
group by CAST(DATEADD(WEEK,DATEDIFF(week,0,movement_date),-1) AS DATE), COALESCE(from_location_id, to_location_id) , sku
),
full_table as (
	select 
		COALESCE(sc.WeekStartDate, m.WeekStartDate) AS WeekStartDate,
		COALESCE(sc.LocationID, m.LocationID) AS LocationID,
		COALESCE(sc.ProductSKU, m.ProductSKU) AS ProductSKU,
		CASE 
			WHEN COALESCE(sc.LocationID, m.LocationID) NOT LIKE 'DC%' THEN ISNULL(m.WeeklySalesQty, 0)
			ELSE m.WeeklySalesQty 
		END AS WeeklySalesQty,
		sc.OnHandQuantity,
		CASE
			WHEN COALESCE(sc.LocationID, m.LocationID) NOT LIKE 'DC%' THEN ISNULL(m.NetMovementQty, 0)
			ELSE m.NetMovementQty
		END AS NetMovementQty
	from 
		snapshot_cte as sc
	FULL OUTER JOIN 
		mv_wd as m
	ON 
		sc.LocationID = m.LocationID 
		AND sc.ProductSKU = m.ProductSKU 
		AND sc.WeekStartDate = m.WeekStartDate
)

/*	
SELECT * from full_table
where WeeklySalesQty < NetMovementQty order by WeekStartDate,LocationID,ProductSKU

select * from gold__fact_inventory_exposure__lite where NetMovementQty > WeeklySalesQty order by WeekStartDate,LocationID,ProductSKU


SELECT 
    movement_id,
    movement_date,
    movement_type,
    from_location_id,
    to_location_id,
    qty
*/
FROM silver__inventory_movements__lite
WHERE sku = 'SKU-0001'
  AND (from_location_id = 'WEB' OR to_location_id = 'WEB')
  AND movement_date BETWEEN '2026-12-22' AND '2026-12-28';
