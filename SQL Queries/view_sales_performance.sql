CREATE or ALTER VIEW VW_sales_performance AS (
select 
	CAST(DATEADD(week, DATEDIFF(week, '2026-01-01', sst.transaction_date),'2026-01-01') AS DATE) AS WeekEndDay,
	sst.location_id as TransactionLocationID,
	sst.channel as TransactionChannel,
	slm.location_name AS LocationName,
	slm.region As Region,
	spm.sku AS ProductSKU,
	spm.category AS ProductCategory,
	spm.brand AS ProductBrand,
	sum(qty) AS Quantity,
	sum(unit_price) AS UnitPrice,
	sum(unit_cost) AS UnitCost,
	sum(unit_price * qty) as Revenue,
	sum((unit_price-unit_cost) * qty)as Profit
from 
	silver__sales_transactions__lite as sst
left join 
	silver__location_master__lite as slm
on 
	sst.location_id = slm.location_id
left join silver__product_master__lite as spm
on
	sst.sku = spm.sku
group by
	CAST(DATEADD(week, DATEDIFF(week, '2026-01-01', sst.transaction_date),'2026-01-01') AS DATE),
	sst.location_id ,
	sst.channel ,
	slm.location_name ,
	slm.region ,
	spm.sku ,
	spm.category ,
	spm.brand 
)