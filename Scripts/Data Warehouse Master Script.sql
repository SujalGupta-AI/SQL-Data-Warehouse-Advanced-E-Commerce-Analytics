/*
===================================================================================================
DATA WAREHOUSE ANALYTICS
===================================================================================================
Author: Sujal Gupta
Objective: Transform raw transactional data into strategic business insights using Advanced SQL.
Techniques Used: CTEs, Window Functions (LAG, OVER, PARTITION BY), Dynamic Segmentation, Views.
===================================================================================================
*/

/* ---------------------------------------------------------------------------------------------------
PHASE 1: TEMPORAL & CUMULATIVE ANALYSIS
Business Goal: Understand our sales velocity. Are we growing month-over-month? 
---------------------------------------------------------------------------------------------------
*/

-- 1. High-Level Yearly & Monthly Sales Aggregations
SELECT
    DATETRUNC(month, order_date) AS Order_Month,
    COUNT(DISTINCT customer_key) AS Total_Active_Customers,
    SUM(Sales_amount) AS Total_Revenue,
    SUM(quantity) AS Total_Units_Sold
FROM fact_sales
WHERE order_Date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- 2. Running Totals (Cumulative Revenue) using Window Functions
SELECT
    Order_Date,
    Total_Sales,
    SUM(Total_Sales) OVER(ORDER BY Order_Date) AS Cumulative_Revenue,
    SUM(AVG_Price) OVER(ORDER BY Order_Date) AS Cumulative_AVG_Price
FROM (
    SELECT
        DATETRUNC(month, order_date) AS Order_Date,
        SUM(sales_amount) AS Total_Sales,
        AVG(price) AS AVG_Price
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t;


/* ---------------------------------------------------------------------------------------------------
PHASE 2: YEAR-OVER-YEAR (YoY) PRODUCT PERFORMANCE
Business Goal: Identify which products are outperforming their historical averages and PY sales.
---------------------------------------------------------------------------------------------------
*/

WITH Yearly_Product_Sales AS (
    SELECT
        p.Product_Name,
        DATEPART(year, f.Order_Date) AS Order_Year,
        SUM(f.Sales_Amount) AS Current_Sales
    FROM fact_sales f
    LEFT JOIN dim_products p ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY p.Product_Name, DATEPART(year, f.Order_Date)
)
SELECT
    Order_Year,
    Product_Name,
    Current_Sales,
    
    -- Compare to historical average
    AVG(Current_Sales) OVER(PARTITION BY product_name) AS Historic_AVG_Sales,
    
    -- YoY Growth using LAG()
    LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY order_year) AS Previous_Year_Sales,
    CASE
        WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS YoY_Performance
FROM Yearly_Product_Sales
ORDER BY Product_Name, Order_Year;


/* ---------------------------------------------------------------------------------------------------
PHASE 3: CATEGORY CONTRIBUTION & COST SEGMENTATION
Business Goal: Determine how different product lines contribute to the overall revenue pie.
---------------------------------------------------------------------------------------------------
*/

WITH Category_Analysis AS (
    SELECT
        Category,
        SUM(Sales_amount) AS Sales
    FROM dim_products p
    LEFT JOIN fact_sales f ON f.product_key = p.product_key
    WHERE Category IS NOT NULL AND Sales_amount IS NOT NULL
    GROUP BY Category
)
SELECT
    Category,
    Sales,
    SUM(Sales) OVER() AS Total_Global_Sales,
    -- Calculate Part-to-Whole Percentage dynamically
    CONCAT(ROUND(CAST(Sales AS FLOAT) / SUM(Sales) OVER() * 100, 2), '%') AS Revenue_Contribution
FROM Category_Analysis
ORDER BY Sales DESC;


/* ---------------------------------------------------------------------------------------------------
PHASE 4: DYNAMIC CUSTOMER SEGMENTATION (LTV)
Business Goal: Automatically classify customers into VIPs, Regulars, and New users based on spend.
---------------------------------------------------------------------------------------------------
*/

WITH Customer_Spending_Behaviour AS (
    SELECT
        c.Customer_Key,
        SUM(f.Sales_Amount) AS Lifetime_Value_Sales,
        DATEDIFF(month, MIN(f.order_Date), MAX(f.order_Date)) AS Lifespan_Months
    FROM dim_customers c
    LEFT JOIN fact_sales f ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT
    Customer_Segment,
    COUNT(Customer_Segment) AS Total_Users,
    CONCAT(ROUND(CAST(COUNT(Customer_Segment) AS FLOAT) / SUM(COUNT(Customer_Segment)) OVER() * 100, 2), '%') AS Audience_Makeup
FROM(
    SELECT
        Customer_Key,
        CASE	
            WHEN Lifespan_Months >= 12 AND Lifetime_Value_Sales >= 5000 THEN 'VIP'
            WHEN Lifespan_Months >= 12 AND Lifetime_Value_Sales < 5000 THEN 'Regular'
            WHEN Lifespan_Months < 12 THEN 'New'
        END AS Customer_Segment
    FROM Customer_Spending_Behaviour
) t
WHERE Customer_Segment IS NOT NULL
GROUP BY Customer_Segment
ORDER BY Total_Users DESC;


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