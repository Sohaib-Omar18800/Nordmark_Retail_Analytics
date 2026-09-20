CREATE OR ALTER VIEW VW_peak_hours_analysis AS
SELECT 
    DATEPART(HOUR, st.transaction_ts) AS HourOfDay,
    DATENAME(WEEKDAY, st.transaction_date) AS DayOfWeek,    
    sl.location_type AS LocationType,
    st.location_id AS LocationID,
    st.channel AS SalesChannel,
    COUNT(DISTINCT st.transaction_id) AS TotalTransactions,
    SUM(st.qty) AS TotalSalesQuantity,
    ROUND(CAST(SUM(st.qty) AS FLOAT) / NULLIF(COUNT(DISTINCT st.transaction_id), 0), 2) AS AvgItemsPerTransaction

FROM silver__sales_transactions__lite st
LEFT JOIN silver__location_master__lite sl 
    ON st.location_id = sl.location_id
GROUP BY 
    DATEPART(HOUR, st.transaction_ts),
    DATENAME(WEEKDAY, st.transaction_date),
    sl.location_type,
    st.location_id,
    st.channel;