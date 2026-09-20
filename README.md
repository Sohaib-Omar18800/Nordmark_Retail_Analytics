# 📊 Nordmark Retail Analytics & Supply Chain Executive Dashboard

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![T-SQL](https://img.shields.io/badge/T--SQL-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Supply Chain Analytics](https://img.shields.io/badge/Domain-Supply_Chain_%26_Retail-blue?style=for-the-badge)

## 📌 Business Problem & Project Overview
Nordmark is a multi-channel retail Enterprise operating physical stores across key cities (Oslo, Bergen, Trondheim) and an online store. 

The management faced challenges in balancing inventory levels across branches, optimizing replenishment schedules, identifying top/bottom-performing products, and analyzing peak customer purchasing hours.

This project delivers an end-to-end Enterprise Analytics Solution—combining **Data Modeling in SQL Server** via custom Analytics Views with an interactive, executive-ready **Power BI Dashboard**.

---

## 🛠️ Data Architecture & SQL Modeling
The data pipeline transforms raw transactional and snapshot tables into optimized analytical views:

* **`VW_sales_performance`**: Aggregates weekly revenue, profit margins, unit costs, and transaction volumes by region and location.
* **`VW_overstock_analysis`**: Calculates **Weeks of Supply (WOS)** to identify overstocked items and provides actionable flags (e.g., *Stop DC Transfer*, *Replenishment Needed*).
* **`VW_pareto_effect`**: Implements **ABC Inventory Classification** (Pareto Principle 80/20) using Window Functions to group products into Fast, Medium, and Slow movers based on revenue contribution.
* **`VW_stockout`**: Evaluates inventory snapshot thresholds to categorize stock status into *In Stock*, *Low Stock*, and *Out of Stock*.
* **`VW_peak_hours_analysis`**: Analyzes transaction density by hour of the day and day of the week to assist in store staffing optimization.
* **`VW_inventory_turnover`**: Tracks inventory velocity across product categories and retail channels.

---

## 📈 Key Dashboard Features

1. **Executive Metrics Overview:** High-level KPIs including Total Revenue ($1.66M), Total Profit ($654K), Average Order Value (AOV), and Total Transactions.
2. **Sales & Profitability Analysis:** Weekly trends comparing Revenue vs. Profit alongside category contribution breakdowns.
3. **Product & Inventory Health:** 
   * ABC Analysis Donut Chart (Class A/B/C classification).
   * Stock Status breakdowns highlighting Severe Overstock vs. Healthy levels.
   * Dynamic Top 10 / Bottom 10 Product performance toggles.
4. **Store & Operations Analytics:**
   * Channel and location revenue distribution.
   * Peak Hours Matrix by day and hour for operational planning.
   * Granular Drill-Through page for detailed SKU-level inventory actions.

---

## 📁 Repository Structure
```text
.
├── SQL Queries/
│   ├── Fact_Table_Inventory.sql
│   ├── VW_sales_performance.sql
│   ├── VW_stockout.sql
│   ├── VW_overstock_analysis.sql
│   ├── VW_pareto_effect.sql
│   ├── VW_inventory_turnover.sql
│   ├── VW_peak_hours_analysis.sql
│   └── VW_drillthrough.sql
├── Dashboard/
│   ├── Nordmark_PBI_GH.pbix
│   └── Nordmark_PBI_GH.pdf
├── Data Source/
│   └── supply_Chain.rar
└── README.md
```

---

## 👤 Author
**Sohaib Omar**
* Data Engineer & Analyst
* [LinkedIn Profile](https://www.linkedin.com/in/sohaib-omar-188oo/) | [GitHub Repository](https://github.com/Sohaib-Omar18800)
