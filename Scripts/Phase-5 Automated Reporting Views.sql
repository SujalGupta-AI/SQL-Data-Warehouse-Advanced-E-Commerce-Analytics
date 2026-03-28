/* ---------------------------------------------------------------------------------------------------
PHASE 5: AUTOMATED REPORTING VIEWS
Business Goal: Create clean, production-ready views to feed directly into BI tools (Tableau/PowerBI).
---------------------------------------------------------------------------------------------------
*/

-- VIEW 1: Comprehensive Customer 360 Report
CREATE VIEW dbo.report_customers AS
WITH Base_Query AS (
    SELECT
        f.order_number, f.order_date, f.sales_amount, f.quantity,
        c.Customer_Key, c.Customer_Number,
        CONCAT(c.first_name, ' ', c.last_name) AS Customer_Name,
        DATEDIFF(year, Birthdate, GETDATE()) AS Age
    FROM fact_sales f
    LEFT JOIN dim_customers c ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
), 
Customer_Aggregation AS (
    SELECT
        Customer_Key, Customer_Number, Customer_Name, age,
        COUNT(order_number) AS No_of_Orders,
        SUM(sales_amount) AS Total_sales,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS Lifespan,
        MAX(order_date) AS Last_Order
    FROM Base_Query
    GROUP BY Customer_Key, Customer_Number, Customer_Name, age
)
SELECT
    *,
    -- Dynamic Age Demographics
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and Above'
    END AS Age_Group,
    
    DATEDIFF(month, Last_Order, GETDATE()) AS Recency_Months,
    
    -- KPI: Average Order Value (AOV)
    CASE WHEN No_of_Orders = 0 THEN 0 ELSE Total_sales / No_of_Orders END AS AVG_Order_Value
FROM Customer_Aggregation;

SELECT
    *
FROM Report_Customers;

-- VIEW 2: Comprehensive Product Performance Report
CREATE VIEW report_products AS
WITH Product_aggregation AS (
    SELECT
        p.product_key, p.product_name, p.category, p.cost,
        SUM(f.sales_amount) AS Total_Sales,
        COUNT(DISTINCT f.order_number) AS Total_Orders,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS Lifespan,
        MAX(f.order_date) AS Last_Order
    FROM fact_sales f
    LEFT JOIN dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL 
    GROUP BY p.product_key, p.product_name, p.category, p.cost
)
SELECT
    *,
    -- Tiering Products by Revenue Performance
    CASE		
        WHEN Total_Sales > 50000 THEN 'High-Performance'
        WHEN Total_Sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performance'
    END AS Product_Segment,
    
    -- KPI: Average Monthly Revenue
    CASE WHEN lifespan = 0 THEN total_sales ELSE total_sales / lifespan END AS AVG_Monthly_Revenue
FROM Product_aggregation;

SELECT
    *
FROM Report_Products;