# End-to-End SQL Data Warehouse & Advanced E-Commerce Analytics

## Executive Summary
This project demonstrates the design, implementation, and analysis of a robust Data Warehouse (DWH) tailored for an e-commerce business. Transitioning from transactional data, I designed a specialized Star Schema database architecture to support complex business intelligence. Leveraging advanced SQL (window functions, CTEs, dynamic segmentation), I developed a five-phase analytical framework. This framework moves from temporal trend analysis to Year-over-Year (YoY) performance, profitability segmentation, dynamic Customer Lifetime Value (LTV) segmentation, and finally, automating reporting through optimized views. The actionable insights generated empower stakeholders to optimize inventory, target high-value customers, and manage product margins effectively.

## Business Problem
The business is struggling to make strategic decisions because its data is siloed within transactional systems that are optimized for speed, not reporting. This makes it extremely difficult to answer critical business questions, such as:
* Which product categories are truly driving profit versus just revenue?
* How does our current sales performance compare to the same period last year?
* Who are our high-value customers, and how can we segment them for targeted marketing based on their lifetime value?
* What are our running sales totals (Year-to-Date) and temporal trends?

To solve this, the business requires a dedicated analytical environment (Data Warehouse) and a suite of pre-built, advanced analytical models to drive growth and operational efficiency.

## Methodology
The project follows a structured data warehousing and analytical lifecycle, separated into logical phases.

### 1. Architecture Design & Implementation
* **Source File:** `Data Warehouse Master Script.sql`
* Designed and implemented a classic Star Schema Data Warehouse optimized for analytical querying.
* The design consists of a central `Fact_Sales` table linked to several key dimension tables: `Dim_Product`, `Dim_Customer`, `Dim_Location`, and `Dim_Date`. This separation allows for flexible and performant slicing and dicing of business data.

![Data Warehouse Star Schema Snapshot](Data%20Warehouse%20Snapshot.png)

### 2. Analytical Phasing (SQL Development)
The analytical work is divided into five specialized phases, each addressing a specific business intelligence need:

* **Phase 1: Temporal & Cumulative Analysis (`Phase-1 Temporal & Cumulative Analysis.sql`):** Establishes baseline performance by analyzing trends over time. Includes time-series decomposition and calculating Year-to-Date (YTD) running totals for revenue and volume.
* **Phase 2: Year-Over-Year (YoY) Product Performance (`Phase-2 Year-Over-Year (YoY) Product Performance.sql`):** Leverages window functions (like `LAG`) to compare current period performance against the same period last year at the product and category level. This identifies growing and shrinking segments.
* **Phase 3: Profitability & Cost Segmentation (`Phase-3 Category Contribution & Cost Segmentation.sql`):** Shifts focus from revenue to profit. Calculates margins and contribution margins by category and segments products based on cost structures to identify profitability bottlenecks.
* **Phase 4: Dynamic Customer Segmentation (LTV) (`Phase-4 Dynamic Customer Segmentation (LTV).sql`):** Implements dynamic segmentation (e.g., high/medium/low value) based on RFM principles and calculated Customer Lifetime Value (LTV). Segments are designed to update automatically as new data flows into the DWH.
* **Phase 5: Automated Reporting Views (`Phase-5 Automated Reporting Views.sql`):** Encapsulates the complex logic developed in previous phases into simplified SQL `VIEW`s. These views provide a "single source of truth" for business users and BI tools (like Tableau/Power BI) to access pre-calculated metrics.

## Skills
* **Data Modeling:** Star Schema Design, Dimension Modeling (Fact & Dimension Tables)
* **Database Administration (DDL):** Schema creation, table constraints, relationships (Primary/Foreign Keys)
* **Advanced SQL (DML):** Window Functions (`RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `OVER`), Common Table Expressions (CTEs), Subqueries, Complex Joins, Aggregations
* **Business Intelligence & Analytics:** Temporal Analysis, YoY Reporting, Cumulative Metrics (YTD), Financial Segmentation (Margin Analysis), Customer Analytics (LTV/RFM Segmentation)
* **Automation:** Creating SQL Views for streamlined reporting.

## Results & Business Recommendation

### Key Analytical Insights
*(Note: These are simulated results based on the types of analysis implemented in the SQL files)*

1.  **Product Performance (YoY):** Phase 2 analysis reveals that while the **** category has the highest revenue, its Year-over-Year growth is stagnant at **[Insert %]**. Conversely, the **[Insert Category Name]** category, though smaller, is growing at **[Insert %]** YoY.
2.  **Profitability:** Phase 3 analysis shows that **[Insert Product Category]** contributes **[Insert %]** of total profit despite only accounting for **[Insert %]** of total revenue, highlighting high margins. Several high-volume products are operating at near-zero margins due to high cost of goods sold.
3.  **Customer Segmentation:** Phase 4 analysis indicates a classic Pareto Principle situation: the top **20%** of customers (segmented as 'High-Value/Champions') are responsible for **[Insert %]** of total profitability.

### Business Recommendations
1.  **Strategic Inventory Management:** Reallocate resources and warehouse space away from high-volume, low-margin products identified in Phase 3 towards high-growth categories identified in Phase 2.
2.  **Margin Optimization:** Conduct a supplier and pricing review for the low-margin products identified in Phase 3. Consider price adjustments or cost-cutting measures to improve profitability.
3.  **Targeted Marketing Campaigns:** Launch a premium loyalty or exclusive rewards program specifically targeting the 'High-Value' and 'Champions' customer segments identified dynamically in Phase 4 to maximize retention of most profitable clients.

## Next Step
* **BI Dashboarding:** Connect a BI tool (like Power BI, Tableau, or Looker Studio) to the Automated Reporting Views created in Phase 5 to build interactive visual dashboards for stakeholders.
* **Predictive Analytics:** Move from descriptive to predictive analytics by implementing SQL-based forecasting models (e.g., using exponential smoothing) to predict Q1 sales based on historical trends.
* **ETL Automation:** Implement an ETL (Extract, Transform, Load) tool or framework (like dbt or Azure Data Factory) to automate the loading of raw transactional data into this Data Warehouse architecture on a daily basis.
